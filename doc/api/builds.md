# Builds API

## List project builds

Get a list of builds in a project.

```
GET /projects/:id/builds
```

| Attribute | Type    | Required | Description         |
|-----------|---------|----------|---------------------|
| `id`      | integer | yes      | The ID of a project |
| `scope`   | string **or** array of strings | no | The scope of builds to show, one or array of: `pending`, `running`, `failed`, `success`, `canceled`; showing all builds if none provided |

```
curl -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/builds"
```

Example of response

```json
[
    {
        "commit": {
            "author_email": "admin@example.com",
            "author_name": "Administrator",
            "created_at": "2015-12-24T16:51:14.000+01:00",
            "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
            "message": "Test the CI integration.",
            "short_id": "0ff3ae19",
            "title": "Test the CI integration."
        },
        "coverage": null,
        "created_at": "2015-12-24T15:51:21.802Z",
        "download_url": null,
        "finished_at": "2015-12-24T17:54:27.895Z",
        "id": 7,
        "name": "teaspoon",
        "ref": "master",
        "runner": null,
        "stage": "test",
        "started_at": "2015-12-24T17:54:27.722Z",
        "status": "failed",
        "tag": false,
        "user": {
            "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
            "bio": null,
            "created_at": "2015-12-21T13:14:24.077Z",
            "id": 1,
            "is_admin": true,
            "linkedin": "",
            "name": "Administrator",
            "skype": "",
            "state": "active",
            "twitter": "",
            "username": "root",
            "web_url": "http://gitlab.dev/u/root",
            "website_url": ""
        }
    },
    {
        "commit": {
            "author_email": "admin@example.com",
            "author_name": "Administrator",
            "created_at": "2015-12-24T16:51:14.000+01:00",
            "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
            "message": "Test the CI integration.",
            "short_id": "0ff3ae19",
            "title": "Test the CI integration."
        },
        "coverage": null,
        "created_at": "2015-12-24T15:51:21.727Z",
        "download_url": null,
        "finished_at": "2015-12-24T17:54:24.921Z",
        "id": 6,
        "name": "spinach:other",
        "ref": "master",
        "runner": null,
        "stage": "test",
        "started_at": "2015-12-24T17:54:24.729Z",
        "status": "failed",
        "tag": false,
        "user": {
            "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
            "bio": null,
            "created_at": "2015-12-21T13:14:24.077Z",
            "id": 1,
            "is_admin": true,
            "linkedin": "",
            "name": "Administrator",
            "skype": "",
            "state": "active",
            "twitter": "",
            "username": "root",
            "web_url": "http://gitlab.dev/u/root",
            "website_url": ""
        }
    }
]
```

## List commit builds

Get a list of builds for specific commit in a project.

```
GET /projects/:id/repository/commits/:sha/builds
```

| Attribute | Type    | Required | Description         |
|-----------|---------|----------|---------------------|
| `id`      | integer | yes      | The ID of a project |
| `sha`     | string  | yes      | The SHA id of a commit |
| `scope`   | string **or** array of strings | no | The scope of builds to show, one or array of: `pending`, `running`, `failed`, `success`, `canceled`; showing all builds if none provided |

```
curl -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/repository/commits/0ff3ae198f8601a285adcf5c0fff204ee6fba5fd/builds"
```

Example of response

```json
[
    {
        "commit": {
            "author_email": "admin@example.com",
            "author_name": "Administrator",
            "created_at": "2015-12-24T16:51:14.000+01:00",
            "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
            "message": "Test the CI integration.",
            "short_id": "0ff3ae19",
            "title": "Test the CI integration."
        },
        "coverage": null,
        "created_at": "2016-01-11T10:13:33.506Z",
        "download_url": null,
        "finished_at": "2016-01-11T10:14:09.526Z",
        "id": 69,
        "name": "rubocop",
        "ref": "master",
        "runner": null,
        "stage": "test",
        "started_at": null,
        "status": "canceled",
        "tag": false,
        "user": null
    },
    {
        "commit": {
            "author_email": "admin@example.com",
            "author_name": "Administrator",
            "created_at": "2015-12-24T16:51:14.000+01:00",
            "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
            "message": "Test the CI integration.",
            "short_id": "0ff3ae19",
            "title": "Test the CI integration."
        },
        "coverage": null,
        "created_at": "2015-12-24T15:51:21.957Z",
        "download_url": null,
        "finished_at": "2015-12-24T17:54:33.913Z",
        "id": 9,
        "name": "brakeman",
        "ref": "master",
        "runner": null,
        "stage": "test",
        "started_at": "2015-12-24T17:54:33.727Z",
        "status": "failed",
        "tag": false,
        "user": {
            "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
            "bio": null,
            "created_at": "2015-12-21T13:14:24.077Z",
            "id": 1,
            "is_admin": true,
            "linkedin": "",
            "name": "Administrator",
            "skype": "",
            "state": "active",
            "twitter": "",
            "username": "root",
            "web_url": "http://gitlab.dev/u/root",
            "website_url": ""
        }
    }
]
```

## Get a single build

Get a single build of a project

```
GET /projects/:id/builds/:build_id
```

| Attribute  | Type    | Required | Description         |
|------------|---------|----------|---------------------|
| `id`       | integer | yes      | The ID of a project |
| `build_id` | integer | yes      | The ID of a build   |

```
curl -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/builds/8"
```

Example of response

```json
{
    "commit": {
        "author_email": "admin@example.com",
        "author_name": "Administrator",
        "created_at": "2015-12-24T16:51:14.000+01:00",
        "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
        "message": "Test the CI integration.",
        "short_id": "0ff3ae19",
        "title": "Test the CI integration."
    },
    "coverage": null,
    "created_at": "2015-12-24T15:51:21.880Z",
    "download_url": null,
    "finished_at": "2015-12-24T17:54:31.198Z",
    "id": 8,
    "name": "rubocop",
    "ref": "master",
    "runner": null,
    "stage": "test",
    "started_at": "2015-12-24T17:54:30.733Z",
    "status": "failed",
    "tag": false,
    "user": {
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "bio": null,
        "created_at": "2015-12-21T13:14:24.077Z",
        "id": 1,
        "is_admin": true,
        "linkedin": "",
        "name": "Administrator",
        "skype": "",
        "state": "active",
        "twitter": "",
        "username": "root",
        "web_url": "http://gitlab.dev/u/root",
        "website_url": ""
    }
}
```

## Cancel a build

Cancel a single build of a project

```
POST /projects/:id/builds/:build_id/cancel
```

| Attribute  | Type    | Required | Description         |
|------------|---------|----------|---------------------|
| `id`       | integer | yes      | The ID of a project |
| `build_id` | integer | yes      | The ID of a build   |

```
curl -X POST -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/builds/1/cancel"
```

Example of response

```json
{
    "commit": {
        "author_email": "admin@example.com",
        "author_name": "Administrator",
        "created_at": "2015-12-24T16:51:14.000+01:00",
        "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
        "message": "Test the CI integration.",
        "short_id": "0ff3ae19",
        "title": "Test the CI integration."
    },
    "coverage": null,
    "created_at": "2016-01-11T10:13:33.506Z",
    "download_url": null,
    "finished_at": "2016-01-11T10:14:09.526Z",
    "id": 69,
    "name": "rubocop",
    "ref": "master",
    "runner": null,
    "stage": "test",
    "started_at": null,
    "status": "canceled",
    "tag": false,
    "user": null
}
```

## Retry a build

Retry a single build of a project

```
POST /projects/:id/builds/:build_id/retry
```

| Attribute  | Type    | Required | Description         |
|------------|---------|----------|---------------------|
| `id`       | integer | yes      | The ID of a project |
| `build_id` | integer | yes      | The ID of a build   |

```
curl -X POST -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/builds/1/retry"
```

Example of response

```json
{
    "commit": {
        "author_email": "admin@example.com",
        "author_name": "Administrator",
        "created_at": "2015-12-24T16:51:14.000+01:00",
        "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
        "message": "Test the CI integration.",
        "short_id": "0ff3ae19",
        "title": "Test the CI integration."
    },
    "coverage": null,
    "created_at": "2016-01-11T10:13:33.506Z",
    "download_url": null,
    "finished_at": null,
    "id": 69,
    "name": "rubocop",
    "ref": "master",
    "runner": null,
    "stage": "test",
    "started_at": null,
    "status": "pending",
    "tag": false,
    "user": null
}
```
