#!/usr/bin/env elixir
# TODO: Once the community support form is closed, this script can be removed.
# The generated _data files should be kept and maintained directly from that point on.

Mix.install([{:nimble_csv, "~> 1.2"}, {:yaml_elixir, "~> 2.0"}, {:ymlr, "~> 5.0"}, {:req, "~> 0.5"}])

script_dir = __DIR__
data_dir = Path.join([script_dir, "..", "docs", "_data"])
logos_dir = Path.join([script_dir, "..", "docs", "assets", "aegis", "community-supporters"])
File.mkdir_p!(logos_dir)

input_file =
  case System.argv() do
    [f] -> f
    [] -> Path.join(script_dir, "community_supporters.csv")
  end

rows =
  input_file
  |> File.read!()
  |> String.replace_prefix("\uFEFF", "")
  |> NimbleCSV.RFC4180.parse_string(skip_headers: false)

[headers | data_rows] = rows

idx = fn col -> Enum.find_index(headers, &(&1 == col)) end
col = fn row, col_name -> Enum.at(row, idx.(col_name)) end

normalize_url = fn url ->
  url =
    if String.starts_with?(url, "http://") or String.starts_with?(url, "https://") do
      url
    else
      "https://" <> url
    end

  # Rewrite hexdocs.pm/<package>/... to hex.pm/packages/<package>
  case Regex.run(~r|^https?://hexdocs\.pm/([^/]+)|, url) do
    [_, package] -> "https://hex.pm/packages/#{package}"
    nil -> url
  end
end

transliterate = fn str ->
  str
  |> String.downcase()
  |> String.normalize(:nfd)
  |> String.replace(~r/[^a-z0-9\s-]/u, "")
end

slugify = fn str ->
  str
  |> transliterate.()
  |> String.replace(~r/\s+/, "-")
  |> String.replace(~r/-+/, "-")
  |> String.trim("-")
end

image_content_types = ~w[
  image/png image/jpeg image/gif image/webp image/svg+xml image/avif image/x-icon
]

download_logo = fn slug, url, logos_dir ->
  existing =
    logos_dir
    |> File.ls!()
    |> Enum.find(fn f -> Path.rootname(f) == slug end)

  cond do
    # Manually placed file — use it regardless of URL
    existing ->
      IO.puts("  [logo] skipping #{slug} (already exists)")
      "/assets/aegis/community-supporters/#{existing}"

    url == "" ->
      nil

    true ->
      IO.write("  [logo] downloading #{url} ... ")
      ext = url |> String.split("?") |> hd() |> Path.extname() |> String.downcase()
      ext = if ext in ~w[.png .jpg .jpeg .gif .webp .svg .avif .ico], do: ext, else: ""

      case Req.get(url, redirect: true, receive_timeout: 10_000) do
        {:ok, %{status: 200, headers: headers, body: body}} ->
          content_type =
            headers
            |> Enum.find_value(fn {k, v} -> if String.downcase(k) == "content-type", do: v end)
            |> then(fn
              [v | _] -> v
              v when is_binary(v) -> v
              nil -> ""
            end)
            |> String.split(";")
            |> hd()
            |> String.trim()

          if content_type in image_content_types do
            ext =
              if ext != "" do
                ext
              else
                case content_type do
                  "image/png" -> ".png"
                  "image/jpeg" -> ".jpg"
                  "image/gif" -> ".gif"
                  "image/webp" -> ".webp"
                  "image/svg+xml" -> ".svg"
                  "image/avif" -> ".avif"
                  _ -> ".bin"
                end
              end

            dest = Path.join(logos_dir, slug <> ext)
            File.write!(dest, body)
            IO.puts("saved as #{slug}#{ext}")
            "/assets/aegis/community-supporters/#{slug}#{ext}"
          else
            IO.puts("skipped (content-type: #{content_type})")
            nil
          end

        {:ok, %{status: status}} ->
          IO.puts("skipped (HTTP #{status})")
          nil

        {:error, reason} ->
          IO.puts("skipped (error: #{inspect(reason)})")
          nil
      end
  end
end

# --- Company name normalization: map submitted names to canonical names ---
# Use this to merge duplicates or fix naming inconsistencies.

company_name_overrides = %{
  "KK TI Tokyo" => "TI Tokyo"
}

# --- People overrides ---
# Drop people entirely (from people, statements, and all outputs).
# Each entry is a person name string.

dropped_people = [
  "Matthew"
]

# --- Statement overrides ---
# Drop statements that are not real statements (e.g. accidentally entered a URL).
# Each entry is {person_name, statement_text}.

dropped_statements = [
  {"Srikanth Kyatham", "https://hex.pm/packages/ash"},
  # Not a real statement, mildly negative framing
  {"David Matz", "Gleam is cool but pulls in a bunch of dependencies "},
  # Not a statement, just an OWASP label
  {"Nico Hoogervorst", "Owasp A03:2025 Software Supply Chain Failures"},
  # Truncated/incomplete sentence
  {"Parker Selbert", "Our business hinges on our ability to deliver a commercial package that customers can trust. For them to trust our package, they need to "},
  # Not a statement about the grant
  {"Robert French", "Elixir is the future. "},
  # Doesn't address supply chain security or grant goals
  {"Mironov Artem", "I develop applications and recently started learning Erlang/Elixir. In my opinion, this language ecosystem is unique — for my tasks, it's the best solution."}
]

opted_in_rows =
  Enum.filter(data_rows, fn row ->
    col.(row, "Include my name on grant support webpage (Yes)") == "true" and
      col.(row, "Your name") not in dropped_people
  end)

# --- Build companies map (deduplicated by name) ---

companies =
  opted_in_rows
  |> Enum.filter(fn row ->
    col.(row, "Representing (Company)") == "true" and
      col.(row, "Include Company on grant support webpage (Yes)") == "true"
  end)
  |> Enum.map(fn row ->
    name = col.(row, "Company") |> then(&Map.get(company_name_overrides, &1, &1))
    {slugify.(name),
     %{
       "name" => name,
       "size" => col.(row, "Company size"),
       "logo_url" => col.(row, "URL to company logo (png or SVG)")
     }}
  end)
  |> Enum.uniq_by(fn {slug, _} -> slug end)
  |> Enum.sort_by(fn {_, company} -> transliterate.(company["name"]) end)
  |> Enum.map(fn {slug, company} ->
    logo = download_logo.(slug, company["logo_url"], logos_dir)
    company |> Map.delete("logo_url") |> Map.merge(%{"logo" => logo, "slug" => slug})
  end)

# --- Build projects map (deduplicated by url) ---

projects =
  opted_in_rows
  |> Enum.filter(fn row -> col.(row, "Representing (Project)") == "true" end)
  |> Enum.flat_map(fn row ->
    [
      col.(row, "hex or repo url - 1"),
      col.(row, "hex or repo url - 2"),
      col.(row, "hex or repo url - 3")
    ]
    |> Enum.reject(&(&1 == "" or is_nil(&1)))
    |> Enum.map(&normalize_url.(&1))
  end)
  |> Enum.uniq()
  |> Enum.map(fn url ->
    url = String.trim(url)
    cond do
      String.match?(url, ~r|^https?://hex\.pm/packages/([^/]+)/?$|) ->
        [_, name] = Regex.run(~r|^https?://hex\.pm/packages/([^/]+)/?$|, url)
        %{"url" => url, "type" => "hex", "name" => name}

      String.match?(url, ~r|^https?://hex\.pm/orgs/([^/]+)/?$|) ->
        [_, org] = Regex.run(~r|^https?://hex\.pm/orgs/([^/]+)/?$|, url)
        %{"url" => url, "type" => "hex", "name" => org}

      String.match?(url, ~r|^https?://github\.com/([^/]+/[^/]+?)(?:\.git)?/?$|) ->
        [_, repo] = Regex.run(~r|^https?://github\.com/([^/]+/[^/]+?)(?:\.git)?/?$|, url)
        %{"url" => url, "type" => "github", "repo" => repo}

      String.match?(url, ~r|^https?://github\.com/([^/]+)/?$|) ->
        [_, org] = Regex.run(~r|^https?://github\.com/([^/]+)/?$|, url)
        %{"url" => url, "type" => "github", "repo" => org}

      true ->
        label =
          url
          |> String.replace(~r|^https?://|, "")
          |> String.replace(~r|^www\.|, "")
          |> String.trim_trailing("/")

        %{"url" => url, "type" => "other", "label" => label}
    end
  end)
  |> Enum.sort_by(fn p ->
    case p do
      %{"type" => "hex", "name" => name} -> {"hex", String.downcase(name)}
      %{"type" => "github", "repo" => repo} -> {"github", String.downcase(repo)}
      %{"url" => url} -> {"other", String.downcase(url)}
    end
  end)

# --- Build people list, referencing company slugs and project urls ---

people =
  opted_in_rows
  |> Enum.map(fn row ->
    representing_company = col.(row, "Representing (Company)") == "true"
    representing_project = col.(row, "Representing (Project)") == "true"

    company_slug =
      if representing_company and col.(row, "Include Company on grant support webpage (Yes)") == "true" do
        col.(row, "Company") |> then(&Map.get(company_name_overrides, &1, &1)) |> slugify.()
      else
        nil
      end

    project_urls =
      if representing_project do
        [
          col.(row, "hex or repo url - 1"),
          col.(row, "hex or repo url - 2"),
          col.(row, "hex or repo url - 3")
        ]
        |> Enum.reject(&(&1 == "" or is_nil(&1)))
        |> Enum.map(&normalize_url.(&1))
      else
        []
      end

    %{
      "name" => col.(row, "Your name"),
      "company" => company_slug,
      "projects" => project_urls,
      "statement" => col.(row, "Statement supporting the goals of the grant")
    }
  end)
  |> Enum.group_by(& &1["name"])
  |> Enum.map(fn {name, entries} ->
    %{
      "name" => name,
      "companies" => entries |> Enum.map(& &1["company"]) |> Enum.reject(&is_nil/1) |> Enum.uniq(),
      "projects" => entries |> Enum.flat_map(& &1["projects"]) |> Enum.uniq()
    }
  end)
  |> Enum.sort_by(&transliterate.(&1["name"]))

# --- Build statements list ---

statements =
  opted_in_rows
  |> Enum.map(fn row ->
    text = col.(row, "Statement supporting the goals of the grant")

    representing_company = col.(row, "Representing (Company)") == "true"
    representing_project = col.(row, "Representing (Project)") == "true"

    company_slug =
      if representing_company and col.(row, "Include Company on grant support webpage (Yes)") == "true" do
        col.(row, "Company") |> then(&Map.get(company_name_overrides, &1, &1)) |> slugify.()
      else
        nil
      end

    project_urls =
      if representing_project do
        [
          col.(row, "hex or repo url - 1"),
          col.(row, "hex or repo url - 2"),
          col.(row, "hex or repo url - 3")
        ]
        |> Enum.reject(&(&1 == "" or is_nil(&1)))
        |> Enum.map(&normalize_url.(&1))
      else
        []
      end

    %{
      "person" => col.(row, "Your name"),
      "company" => company_slug,
      "projects" => project_urls,
      "text" => text
    }
  end)
  |> Enum.reject(fn s ->
    s["text"] == "" or is_nil(s["text"]) or
      Enum.member?(dropped_statements, {s["person"], s["text"]})
  end)
  |> Enum.sort_by(&transliterate.(&1["person"]))

File.write!(Path.join(data_dir, "aegis_community_companies.yml"), Ymlr.document!(%{"companies" => companies}))
File.write!(Path.join(data_dir, "aegis_community_projects.yml"), Ymlr.document!(%{"projects" => projects}))
File.write!(Path.join(data_dir, "aegis_community_people.yml"), Ymlr.document!(%{"people" => people}))
File.write!(Path.join(data_dir, "aegis_community_statements.yml"), Ymlr.document!(%{"statements" => statements}))

IO.puts("Written: aegis_community_companies.yml (#{length(companies)} companies)")
IO.puts("Written: aegis_community_projects.yml (#{length(projects)} projects)")
IO.puts("Written: aegis_community_people.yml (#{length(people)} people)")
IO.puts("Written: aegis_community_statements.yml (#{length(statements)} statements)")
