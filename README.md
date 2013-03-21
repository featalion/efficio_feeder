EfficioFeeder (RSS/Atom aggregator with WebHooks)
--

EfficioFeeder processes RSS/Atom streams.
Each stream can contain one or more RSS/Atom feeds to process and number of HTTP endpoints to POST new items to.

Fully Cloud-based, uses [Iron.io](http://iron.io) infrastructure.


## How to use

* Clone this repository
* Configure your `iron.json`
* Configure your streams in `config.yaml`
* Upload and schedule


## Configuration

Configuration is placed in two files:

* `iron.json` - configuration for Iron.io libraries
* `config.yaml` - configuration for `EfficioFeeder::Worker`

#### Iron.io services configuration

Basicly, `iron.json` must contain `JSON` with two parameters:

```javascript
{
  "project_id": "PROJECT_ID",
  "token": "TOKEN"
}
```

More on Iron.io services configuration you can find out [there](http://dev.iron.io/mq/reference/configuration/).

#### EfficioFeeder configuration

Typically configuration looks like:

```yaml
streams:
  - feeds:
      - http://featalion.blogspot.com/feeds/posts/default
      - http://blog.iron.io/feeds/posts/default
    subscribers:
      - http://first.your.end.point.com/post_update
      - http://second.your.end.point.com/post_update
    queue_name: feeds_notifications
    cache_name: feeds
    output_type: rss2.0 # rss0.9, rss1.0, rss2.0, atom or atom1.0

```

Parameters:

* `streams`: required, `Array` of `Hash`es which are contains next fields
  * `feeds`: required, `Array` of `String`s. Each element in it will be treat as RSS/Atom feed URL
  * `subscribers: required, `Array of `Strings`. Each element in it will be treated as endpoint URL to POST new feed's items to
  * `queue_name`: required, name of your queue on Iron.io to send stream's new items
  * `cache_name`: required, name of the cache to store latest feeds' data
  * `output_type`: optional, `String` type of the items to POST to endpoint. Acceptable values are `rss0.9`, `rss1.0`, `rss2.0`, `atom`, `atom1.0`.


## Upload and Schedule

First, install `iron_worker_ng` gem
```
gem install iron_worker_ng
```

Then upload and queue (to launch once) or schedule the worker itself
```
iron_worker upload efficio_feeder
iron_worker queue efficio_feeder
```

-------
one or more RSS/Atom feeds to process and number of HTTP endpoints to POST new items to.

Fully Cloud-based, uses [Iron.io](http://iron.io) infrastructure.


## How to use

* Clone this repository
* Configure your `iron.json`
* Configure your streams in `config.yaml`
* Upload and schedule


## Configuration

Configuration is placed in two files:

* `iron.json` - configuration for Iron.io libraries
* `config.yaml` - configuration for `EfficioFeeder::Worker`

#### Iron.io services configuration

Basicly, `iron.json` must contain `JSON` with two parameters:

```javascript
{
  "project_id": "PROJECT_ID",
  "token": "TOKEN"
}
```

More on Iron.io services configuration you can find out [there](http://dev.iron.io/mq/reference/configuration/).

#### EfficioFeeder configuration

Typically configuration looks like:

```yaml
streams:
  - feeds:
      - http://featalion.blogspot.com/feeds/posts/default
      - http://blog.iron.io/feeds/posts/default
    subscribers:
      - http://first.your.end.point.com/post_update
      - http://second.your.end.point.com/post_update
    queue_name: feeds_notifications
    cache_name: feeds
    output_type: rss2.0 # rss0.9, rss1.0, rss2.0, atom or atom1.0

```

Parameters:

* `streams`: required, `Array` of `Hash`es which are contains next fields
  * `feeds`: required, `Array` of `String`s. Each element in it will be treat as RSS/Atom feed URL
  * `subscribers: required, `Array of `Strings`. Each element in it will be treated as endpoint URL to POST new feed's items to
  * `queue_name`: required, name of your queue on Iron.io to send stream's new items
  * `cache_name`: required, name of the cache to store latest feeds' data
  * `output_type`: optional, `String` type of the items to POST to endpoint. Acceptable values are `rss0.9`, `rss1.0`, `rss2.0`, `atom`, `atom1.0`.


## Upload and Schedule

First, install `iron_worker_ng` gem
```
gem install iron_worker_ng
```

Then upload and queue (to launch once) or schedule the worker itself
```
iron_worker upload efficio_feeder
iron_worker queue efficio_feeder
```

-------
one or more RSS/Atom feeds to process and number of HTTP endpoints to POST new items to.

Fully Cloud-based, uses [Iron.io](http://iron.io) infrastructure.


## How to use

* Clone this repository
* Configure your `iron.json`
* Configure your streams in `config.yaml`
* Upload and schedule


## Configuration

Configuration is placed in two files:

* `iron.json` - configuration for Iron.io libraries
* `config.yaml` - configuration for `EfficioFeeder::Worker`

#### Iron.io services configuration

Basicly, `iron.json` must contain `JSON` with two parameters:

```javascript
{
  "project_id": "PROJECT_ID",
  "token": "TOKEN"
}
```

More on Iron.io services configuration you can find out [there](http://dev.iron.io/mq/reference/configuration/).

#### EfficioFeeder configuration

Typically configuration looks like:

```yaml
streams:
  - feeds:
      - http://featalion.blogspot.com/feeds/posts/default
      - http://blog.iron.io/feeds/posts/default
    subscribers:
      - http://first.your.end.point.com/post_update
      - http://second.your.end.point.com/post_update
    queue_name: feeds_notifications
    cache_name: feeds
    output_type: rss2.0 # rss0.9, rss1.0, rss2.0, atom or atom1.0

```

Parameters:

* `streams`: required, `Array` of `Hash`es which are contains next fields
  * `feeds`: required, `Array` of `String`s. Each element in it will be treat as RSS/Atom feed URL
  * `subscribers: required, `Array of `Strings`. Each element in it will be treated as endpoint URL to POST new feed's items to
  * `queue_name`: required, name of your queue on Iron.io to send stream's new items
  * `cache_name`: required, name of the cache to store latest feeds' data
  * `output_type`: optional, `String` type of the items to POST to endpoint. Acceptable values are `rss0.9`, `rss1.0`, `rss2.0`, `atom`, `atom1.0`.


## Upload and Schedule

First, install `iron_worker_ng` gem
```
gem install iron_worker_ng
```

Then upload and queue (to launch once) or schedule the worker itself
```
iron_worker upload efficio_feeder
iron_worker queue efficio_feeder
```

-------
© 2013 Yury Yantsevich