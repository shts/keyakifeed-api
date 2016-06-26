@dir = "/var/www/app/"

worker_processes 3 # CPUのコア数に揃える
working_directory @dir

timeout 300
listen "/var/www/app/tmp/unicorn.sock", backlog: 1024 #数字は何でもよい

pid "#{@dir}tmp/pids/unicorn.pid" #pidを保存するファイル

# unicornは標準出力には何も吐かないのでログ出力を忘れずに
stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"

preload_app true
