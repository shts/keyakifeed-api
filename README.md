
### DB初期化について

db/api.db, db/migrate/schema.rb を削除後、下記コマンドを実行

```
$ bundle exec rake app:create_all
```

### 再起動時に行なうコマンド

TODO: 不要なようにOSで自動起動するよう設定する

**Unicornの起動**

```
$ bundle exec unicorn -E production -c unicorn.rb -D
```

**Nginxの起動**


```
$ nginx
```

＃不要かも

**Crawlerの起動**

```
$ sh deamon_crawler_entries start
```



### デーモンスクリプト操作

実行権限を付与しておくこと

```
$ chmod +x deamon_crawler_entries
```


**開始**

```
$ sh deamon_crawler_entries start
```

or

```
$ ./deamon_crawler_entries start
```


**停止**

```
$ sh deamon_crawler_entries stop
```

**停止＆開始**

```
$ sh deamon_crawler_entries restart
```

### デーモン停止

http://www.mk-mode.com/octopress/2013/10/06/ruby-daemonize-script/
```
$ ps aux | grep {$script_file_name} | grep -v grep
```

ex)
```
$ ps aux | grep crawler.rb | grep -v grep
saitoushouta    15188[pid]   0.0  0.0  2507528   1420   ??  S     2:08PM   0:00.00 ruby crawler.rb
```

```
$ kill -9 {$pid}
```
