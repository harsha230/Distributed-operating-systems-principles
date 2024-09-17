use "collections"

// Boss actor will divide the tasks and distribute among the workers
actor Boss
  let total_items: I64  
  let group_size: I64  
  let _env: Env 
  var _results: Array[I64] = []  

  // initialization the boss actor
  new create(n: I64, k: I64, env: Env) =>
    total_items = n
    group_size = k
    _env = env

  // Method to organize tasks and distribute them to workers
  be organize_tasks() =>
    var total_workers: I64 = 100 // Default number of workers
    if total_items < 100 then
        total_workers = total_items
    end

    // Calculation the work unit size 
    var work_unit: I64 = total_items / total_workers
    // Calculation of the leftover work
    let left_over_work: I64 = total_items % total_workers
    var task_chunks: Array[(I64, I64)] = []  

    var start_chunk: I64 = 1  

    // Handling uneven distribution of work units
    if (((total_items % 2) != 0) or ((total_workers % 2) != 0)) and (left_over_work != 0) then
        // Leftover task distribution
        for worker_range in Range[I64](1, total_workers - 1) do
          let end_chunk: I64 = (worker_range + 1) * work_unit  
          task_chunks.push((start_chunk, end_chunk))  
          start_chunk = end_chunk + 1  
        end
        
        task_chunks.push((start_chunk, total_items))
    else
        // Equal distribution of work among workers
        for worker_range in Range[I64](1, total_workers) do
          let end_chunk: I64 = (worker_range + 1) * work_unit  
          task_chunks.push((start_chunk, end_chunk))  
          start_chunk = end_chunk + 1  
        end
    end
    _env.out.print("Work_unit: " + work_unit.string())
    _env.out.print("result")
    // Assign task to workers 
    for idx in task_chunks.values() do
        let worker = Worker(this, _env)  
        worker.complete_task(idx._1, idx._2, group_size)  
    end

      

// Worker actor checks for perfect square sums
actor Worker
  let _boss: Boss  
  let et: Env  

  // Initialization of the worker 
  new create(boss: Boss, env: Env) =>
    _boss = boss
    et = env

  // Method for the worker to complete its assigned task chunk
  be complete_task(start_chunk: I64, end_chunk: I64, group_size: I64) =>
    for num in Range[I64](start_chunk, end_chunk + 1) do
      if check_perfect_square_sum(num, group_size) then
        et.out.print(num.string())
      end
    end

  // checking if consecutive squares sum is a perfect square
  fun check_perfect_square_sum(start_chunk: I64, group_size: I64): Bool =>
    var sum_of_squares: I64 = 0  
    for num in Range[I64](start_chunk, (start_chunk + group_size)) do
      sum_of_squares = sum_of_squares + (num * num)
    end

    
    let sqrt = integer_sqrt(sum_of_squares)
    (sqrt * sqrt) == sum_of_squares

fun integer_sqrt(n: I64): I64 =>
  if n == 0 then
    0
  else
    var approx1: I64 = n
    var approx2: I64 = (approx1 + (n / approx1)) / 2
    while approx2 < approx1 do
      approx1 = approx2
      approx2 = (approx1 + (n / approx1)) / 2
    end
    approx1
    end

// Main function
actor Main
  new create(env: Env) =>
    try
      let args = env.args  
      let n = args(1)?.i64()?  
      let k = args(2)?.i64()?  
      let boss = Boss(n, k, env)  
      boss.organize_tasks()  
    else
      env.out.print("Invalid arguments")  
    end