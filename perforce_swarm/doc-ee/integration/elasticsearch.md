# Elasticsearch integration

[Elasticsearch] is a flexible, scalable and powerful search service.

If you want to keep GitSwarm EE's search fast when dealing with huge amount
of data, you should consider [enabling
Elasticsearch](#enable-elasticsearch).

GitSwarm EE leverages the search capabilities of Elasticsearch and enables
it when searching in:

- GitSwarm EE
- issues
- merge requests
- milestones
- notes
- projects
- repositories
- snippets
- wiki repositories

Once the data is added to the database, search indexes are updated
automatically. Elasticsearch can be installed on the same machine that
GitLab is installed or on a separate server.

## Requirements

These are the minimum requirements needed for Elasticsearch to work:

- GitSwarm EE 2016.1+
- Elasticsearch 2.0+

## Install Elasticsearch

Providing detailed information on installing Elasticsearch is out of the
scope of this document.

You can follow the steps as described in the [official web site][install]
or use the packages that are available for your OS.

## Enable Elasticsearch

In order to enable Elasticsearch you need to have access to the server that
GitSwarm EE is hosted on.

The following three parameters are needed to enable Elasticsearch:

| Parameter | Description |
| --------- | ----------- |
| `enabled` | Enables/disables the Elasticsearch integration. Can be either `true` or `false` |
| `host`    | The host where Elasticsearch is installed on. Can be either an IP or a domain name which correctly resolves to an IP. It can be changed in the [Elasticsearch configuration settings][elastic-settings]. The default value is `localhost` |
| `port`    | The TCP port that Elasticsearch listens to. It can be changed in the [Elasticsearch configuration settings][elastic-settings]. The default value is `9200`  |

### Enable Elasticsearch

Edit `/etc/gitswarm/gitswarm.rb` and add the following lines:

```ruby
gitlab_rails['elasticsearch'] = [
  {
    "enabled" => "true",
    "host" => "localhost",
    "port" => 9200
  }
]
```

Replace the values as you see fit according to the [settings table
above](#enable-elasticsearch).

Save the file and reconfigure GitSwarm EE for the changes to take effect:
`sudo gitswarm-ctl reconfigure`.

As a last step, move on to [add GitSwarm EE's data to the Elasticsearch
index](#add-gitlabs-data-to-the-elasticsearch-index).

## Add GitSwarm EE's data to the Elasticsearch index

After [enabling Elasticsearch](#enable-elasticsearch), you must run the
following rake tasks to add GitSwarm EE's data to the Elasticsearch index.

It might take a while depending on how big your Git repositories are.

---

To index all your repositories:

```bash
sudo gitswarm-rake gitlab:elastic:index_repositories
```

If you want to run several tasks in parallel (probably in separate terminal
windows) you can provide the `ID_FROM` and `ID_TO` parameters:

```bash
ID_FROM=1001 ID_TO=2000 sudo gitswarm-rake gitlab:elastic:index_repositories
```

Both parameters are optional. Keep in mind that this task skips
repositories (and certain commits) that have already been indexed. It
stores the last commit SHA of every indexed repository in the database. As
an example, if you have 3,000 repositories and you want to run three
separate indexing tasks, you might run:

```
ID_TO=1000 sudo gitswarm-rake gitlab:elastic:index_repositories
ID_FROM=1001 ID_TO=2000 sudo gitswarm-rake gitlab:elastic:index_repositories
ID_FROM=2001 sudo gitswarm-rake gitlab:elastic:index_repositories
```

To index all wikis:

```bash
sudo gitswarm-rake gitlab:elastic:index_wikis
```

The wiki indexer also supports the `ID_FROM` and `ID_TO` parameters if you
want to limit a project set.

To index all database entities:

```bash
sudo gitswarm-rake gitlab:elastic:index_database
```

## Disable Elasticsearch

Disabling the Elasticsearch integration is as easy as setting `enabled` to
`false` in your GitLab settings. See [Enable
Elasticsearch](#enable-elasticsearch) to find where those settings are and
don't forget to reconfigure/restart GitSwarm EE for the changes to take
effect.

To minimize downtime of the search feature we recommend the following:

1. Configure Elasticsearch in `/etc/gitswarm/gitswarm.rb`, but do not
   enable it, just set a host and port.

1. Create empty indexes:

    ```bash
    sudo gitswarm-rake gitlab:elastic:create_empty_indexes
    ```

1. Index all repositories using the `gitlab:elastic:index_repositories`
   Rake task (see above). You'll probably want to do this in parallel.

1. Enable Elasticsearch and restart GitSwarm EE.

1. Run indexers for database, wikis, and repositories. By running the
   repository indexer twice you can be sure that everything is indexed
   because some commits could be pushed while you performed initial
   indexing. The repository indexer skips repositories and commits that
   are already indexed, so subsequent runs are much shorter than the first
   run.

[elasticsearch]: https://www.elastic.co/products/elasticsearch "Elasticsearch website"
[install]: https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html "Elasticsearch installation documentation"
[elastic-settings]: https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration.html#settings "Elasticsearch configuration settings"
