# Nimrod wrapper around the Netflix Roulette API (http://netflixroulette.net/api/).

# Written by Adam Chesak.
# Released under the MIT open source license.

## Usage examples:
##
## Get info about Dr. Strangelove, and output the summary and list of cast.
##
## .. code-block:: nimrod
##
##    var strangelove : NRShow = getTitle("Dr. Strangelove")
##    echo("Dr. Strangelove summary: " & strangelove.summary)
##    echo("Dr. Strangelove cast: " & strangelove.showCast)
##    
##    # Output:
##    
##    # Dr. Strangelove summary: When a fanatical U.S. general launches an air strike against the Soviets, they raise the stakes by threatening to unleash a "doomsday device," setting the stage for Armageddon in this classic black comedy that brilliantly skewers the nuclear age.
##    # Dr. Strangelove cast: Peter Sellers, George C. Scott, Sterling Hayden, Keenan Wynn, Slim Pickens, Peter Bull, James Earl Jones, Tracy Reed, Jack Creley, Glenn Beck
##
##    
## Get info about all films directed by Andrei Tarkovsky, and output the
## titles of the films and their release year.
##
## .. code-block:: nimrod
##
##    var tarkovsky : seq[NRShow] = getDirector("Andrei Tarkovsky")
##    echo("\nFilms directed by Andrei Tarkovsky:")
##    for i in tarkovsky:
##        echo(i.showTitle & " - " & i.releaseYear)
##    
##    # Output:
##    
##    # Films directed by Andrei Tarkovsky:
##    # Stalker - 1979
##    # Nostalghia - 1983
##    # The Sacrifice - 1986
##
##
## Get info about all films starring Arnold Schwarzenegger, and output the
## titles of the films, their runtime, and their category.
##
## .. code-block:: nimrod
##
##    var arnold : seq[NRShow] = getActor("Arnold Schwarzenegger")
##    for i in arnold:
##        echo(i.showTitle & " - " & i.runtime & " - " & i.category)
##    
##    # Output:
##    
##    # Milius - 103 min - Documentaries
##    # The Running Man - 101 min - Sci-Fi & Fantasy
##    # The Terminator - 107 min - Action & Adventure
##    # Last Action Hero - 130 min - Action & Adventure
##    # The Last Stand - 107 min - Action & Adventure
##    # Terminator 2: Judgment Day - 137 min - Action & Adventure
##    # Killer at Large: Why Obesity is America's Greatest Threat - None - Documentaries
##    # The Expendables 2 - 103 min - Action & Adventure
##    # Conan the Destroyer - 103 min - Action & Adventure
##    # Running with Arnold - 72 min - Documentaries
##    # Pumping Iron - N/A - Classic Movies



import httpclient
import json
import cgi


type NRShow* = tuple[unit : int, showID : int, showTitle : string, releaseYear : string, rating : string,
                     category : string, showCast : string, director : string, summary : string, poster : string,
                     mediaType : int, runtime : string]


proc parseShow(data : JsonNode): NRShow = 
    ## Internal proc to convert the data from json to an NRShow.
    
    var show : NRShow
    
    show.unit = int(data["unit"].num)
    show.showID = int(data["show_id"].num)
    show.showTitle = data["show_title"].str
    show.releaseYear = data["release_year"].str
    show.rating = data["rating"].str
    show.category = data["category"].str
    show.showCast = data["show_cast"].str
    show.director = data["director"].str
    show.summary = data["summary"].str
    show.poster = data["poster"].str
    show.mediaType = int(data["mediatype"].num)
    if data.hasKey("runtime"):
        show.runtime = data["runtime"].str
    
    return show


proc getTitle*(title : string): NRShow = 
    ## Returns info about the specified title.
    
    var response : string = getContent("http://netflixroulette.net/api/api.php?title=" & encodeURL(title))
    var data : JsonNode = parseJson(response)
    
    return parseShow(data)


proc getTitle*(title : string, year : string): NRShow = 
    ## Returns info about the specified title from the specified year.
    
    var url : string = "http://netflixroulette.net/api/api.php?title=" & encodeURL(title)
    url &= "&year=" & encodeURL(year)
    
    var response : string = getContent(url)
    var data : JsonNode = parseJson(response)
    
    return parseShow(data)


proc getDirector*(director : string): seq[NRShow] = 
    ## Returns a seq containing info about the titles by the specified director.
    
    var url : string = "http://netflixroulette.net/api/api.php?director=" & encodeURL(director)
    
    var response : string = getContent(url)
    var data : JsonNode = parseJson(response)
    
    var directors = newSeq[NRShow](len(data))
    for i in 0..len(data)-1:
        directors[i] = parseShow(data[i])
    
    return directors


proc getActor*(actor : string): seq[NRShow] = 
    ## Returns a seq containing info about the titles in which the specified actor appeared.
    
    var url : string = "http://netflixroulette.net/api/api.php?actor=" & encodeURL(actor)
    
    var response : string = getContent(url)
    var data : JsonNode = parseJson(response)
    
    var actors = newSeq[NRShow](len(data))
    for i in 0..len(data)-1:
        actors[i] = parseShow(data[i])
    
    return actors


when isMainModule:
    
    # Get info about Dr. Strangelove, and output the summary and list of cast.
    var strangelove : NRShow = getTitle("Dr. Strangelove")
    echo("Dr. Strangelove summary: " & strangelove.summary)
    echo("Dr. Strangelove cast: " & strangelove.showCast)
    
    # Get info about all films directed by Andrei Tarkovsky, and output the
    # titles of the films and their release year.
    var tarkovsky : seq[NRShow] = getActor("Arnold Schwarzenegger")
    for i in tarkovsky:
        echo(i.showTitle & " - " & i.runtime & " - " & i.category)
    