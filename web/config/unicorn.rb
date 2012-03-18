# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 2

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "/opt/cloudengine/current/cescheduler" # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
# listen "/tmp/.sock", :backlog => 64
#listen "/opt/cloudengine/shared/tmp/sockets/unicorn.cloudengine.sock"

timeout 60

listen 3600

# feel free to point this anywhere accessible on the filesystem
pid "/opt/cloudengine/shared/tmp/pids/unicorn_sched.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "/opt/cloudengine/shared/log/unicorn.stderr.log"
stdout_path "/opt/cloudengine/shared/log/unicorn.stdout.log"

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app false

before_fork do |server, worker|
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  #
  # # *optionally* throttle the master from forking too quickly by sleeping
  # sleep 1
end

after_fork do |server, worker|
  srand
end

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "/opt/cloudengine/current/cescheduler/Gemfile"
end
