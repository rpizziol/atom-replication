using Jedis

# Set up channels, publisher and subscriber clients
channels = ["sys"]
subscriber = Client(host="localhost", port=6379)

# Begin the subscription
stop_fn(msg) = msg[end] == "close";  # stop the subscription loop if the message matches

subscribe(channels...; stop_fn=stop_fn, client=subscriber) do msg
    println(msg)#qui da inserire l'invocazione del problema di ottimizzazione
end  # Without @async this function will block, alternatively use Thread.@spawn
