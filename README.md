
### 初期化について

db/api.db, db/migrate/schema.rb を削除後、下記コマンドを実行

```
$ bundle exec rake app:create_all
```

### 再起動時に行なうコマンド

Unicornの起動

```
$ bundle exec unicorn -E production -c unicorn.rb -D
```

nginxの起動


```
$ nginx
```

＃不要かも
