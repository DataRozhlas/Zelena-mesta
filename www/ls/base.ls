mesta = topojson.feature ig.data['krajska-mesta'], ig.data['krajska-mesta'].objects.data

cities = ["Olomouc" "České Budějovice" "Praha" "Plzeň" "Ústí nad Labem" "Ostrava" "Karlovy Vary" "Pardubice" "Liberec" "Hradec Králové" "Brno" "Zlín" "Jihlava"]
citiesNoDiacritics = ["Olomouc" "Ceske Budejovice" "Praha" "Plzen" "Usti nad Labem" "Ostrava" "Karlovy Vary" "Pardubice" "Liberec" "Hradec Kralove" "Brno" "Zlin" "Jihlava"]
cityToDraw = 13 %% cities.length

document.title = citiesNoDiacritics[cityToDraw]
console.log cities[cityToDraw]

prg = mesta.features.filter -> it.properties.NAZOB == cities[cityToDraw]
w = 230
padding = 10
{width, height, projection} = ig.utils.geo.getFittingProjection prg, w - 2 * padding
projection.translate [padding, padding]
fullWidth = width + 2 * padding
fullHeight = height + 2 * padding

tile = d3.geo.tile!
  ..size [fullWidth, fullHeight]
  ..scale projection.scale! * 2 * Math.PI
  ..translate projection [0 0]
  ..zoomDelta ((window.devicePixelRatio || 1) - 0.5)

tiles = tile!

path = d3.geo.path!
  ..projection projection
container = d3.select ig.containers.base
svg = container.append \svg
  ..attr \width fullWidth
  ..attr \height fullHeight
  ..append \mask
    ..attr \id \mesto
    ..append \rect
      ..attr \x 0
      ..attr \y 0
      ..attr \width fullWidth
      ..attr \height fullHeight
      ..attr \fill '#060606'
    ..append \path
      ..attr \fill '#888'
      ..attr \d path prg.0
  ..append \path
    ..attr \class \border
    ..attr \d path prg.0
  ..append \g
    ..attr \class \map-tiles
    ..attr \mask 'url(#mesto)'
    ..append \g
      ..attr \transform "scale(#{tiles.scale}) translate(#{tiles.translate})"
      ..selectAll \image .data tiles .enter!append \image
        ..attr \xlink:href -> "https://samizdat.cz/tiles/ton_b1/#{it.2}/#{it.0}/#{it.1}.png"
        ..attr \width 1
        ..attr \height 1
        ..attr \x -> it.0
        ..attr \y -> it.1

zelen = topojson.feature ig.data.zelen, ig.data.zelen.objects.data
zelenPrg = zelen.features.filter -> it.properties.CITIES == citiesNoDiacritics[cityToDraw]

svg.append \g .attr \class \zelen
  .selectAll \path .data zelenPrg .enter!append \path
    ..attr \d -> path it
    ..attr \class ->
      | it.properties.ITEM == "Green urban areas" => "park"
      | otherwise                                 => "forest"
