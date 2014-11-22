require 'resque/tasks'

# preload the rails environment
task "resque:setup" => :environment

namespace :resque do
  desc "Clear pending tasks"
  task :clear => :environment do
    queues = Resque.queues
    queues.each do |queue_name|
      puts "Clearing #{queue_name}..."
      Resque.remove_queue queue_name
    end
  end

  desc "list workers"
  task :list_workers => :environment do
    if Resque.workers.any?
      Resque.workers.each do |worker|
        puts "#{worker} (#{worker.state})"
      end
    else
      puts "None"
    end
  end

  desc "list queues"
  task :list_queues => :environment do
    Resque.queues.each do |queue|
      puts"Queue #{queue}: #{Resque.size(queue)}"
    end
  end

  desc "kill all workers"
  task :kill_workers => :environment do
    if Resque.workers.any?
      Resque.workers.each do |worker|
        abort "** resque kill WORKER_ID" if worker.nil?
        pid = worker.split(':')[1].to_i

        begin
          Process.kill("KILL", pid)
          puts "** killed #{worker}"
        rescue Errno::ESRCH
          puts "** worker #{worker} not running"
        end

        remove worker
      end
    end
  end

  def remove(worker)
    abort "** resque remove WORKER_ID" if worker.nil?

    Resque.remove_worker(worker)
    puts "** removed #{worker}"
  end 

end