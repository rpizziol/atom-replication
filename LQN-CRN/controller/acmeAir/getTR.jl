function getTr(mongoClient,window,msName)
    database = mongoClient[msName]
    RT = database["rt"]
    bson_filter = Mongoc.BSON("""{}""")
    bson_options = Mongoc.BSON("""{"sort" : { "end" : -1 } }""")
    evt=Mongoc.find_one(RT, bson_filter, options=bson_options)

    if(typeof(evt)==Nothing)
       res=nothing;
    else
        last=max(evt["end"]-(window*10^3),0)
        bson_filter = Mongoc.BSON(@sprintf("""{"end":{"\$gt":%d}}""",last))
        res=length(RT,bson_filter)/window
    end
    return res
end
