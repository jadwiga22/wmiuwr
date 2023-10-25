using Dates

function generate()
    for i in 1:100
        println(string(Time(rand(DateTime(2000, 1, 1, 0, 0):Second(1):DateTime(2010, 12, 31, 0, 0)))), " ", "23.45.67.", rand(95:99),  " ",  "GET /TheApplication/WebResource.axd 200")
    end
end
