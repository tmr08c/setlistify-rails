@PlaylistBuilder = class PlaylistBuilder
  constructor: (artistName, venueName, date, setlist) ->
    @artistName = artistName
    @venueName = venueName
    @date = date
    @setlist = setlist
    @api = new SpotifyApi()

  buildPlaylist: (onSuccess, onFailure) =>
    @_createPlaylist().then((playlistResult) =>
      playlistId = playlistResult.id
      $.when.apply(undefined, @_getSongUris()).then((results) =>
        songInfoResponses = [].slice.apply(arguments)
        @_addTracksToPlaylist(playlistId, songInfoResponses )
      )
    )

  _createPlaylist: () ->
    console.log "In 'createPlaylist'"
    @api.createPlaylist(@_playlistName())

  _getSongUris: () ->
    console.log "In 'getSongUris'"
    console.log @setlist

    requests = []
    for song in @setlist
      requests.push(@api.songSearch(@artistName, song.title))
    console.log(requests)
    requests

  _addTracksToPlaylist: (playlistId, songInfoResponses) ->
    console.log "In 'addTracksToPlaylist'. playlistId: #{playlistId} / songUris: #{songUris}"
    songUris = []

    songInfoResponses.forEach (songInfoResponse, _) ->
      # If the song is found by the API, add it to our array of Song IDs
      if songInfoResponse[0].tracks.items.length > 0
        songUris.push songInfoResponse[0].tracks.items[0].uri
      else
        console.log "Couldn't find song"
    @api.addToPlaylist(songUris, playlistId)

  _playlistName: ->
    "#{@artistName} - #{@venueName} (#{@date})"
