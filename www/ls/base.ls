mesta = topojson.feature ig.data['krajska-mesta'], ig.data['krajska-mesta'].objects.data

prg = mesta.features.filter -> it.properties.NAZOB == "Praha"
w = 630
{width, height, projection} = ig.utils.geo.getFittingProjection prg, w
tile = d3.geo.tile!
  ..size [width, height]
  ..scale projection.scale! * 2 * Math.PI
  ..translate projection [0 0]
  ..zoomDelta ((window.devicePixelRatio || 1) - 0.5)

tiles = tile!

path = d3.geo.path!
  ..projection projection
container = d3.select ig.containers.base
svg = container.append \svg
  ..attr \width width
  ..attr \height height
  ..append \mask
    ..attr \id \mesto
    ..append \rect
      ..attr \x 0
      ..attr \y 0
      ..attr \width width
      ..attr \height height
      ..attr \fill '#101010'
    ..append \path
      ..attr \fill '#ccc'
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
zelenPrg = zelen.features.filter -> it.properties.CITIES == "Praha"
console.log zelenPrg.0.properties
svg.append \g .attr \class \zelen
  .selectAll \path .data zelenPrg .enter!append \path
    ..attr \d -> path it
    ..attr \class ->
      | it.properties.ITEM == "Green urban areas" => "park"
      | otherwise                                 => "forest"
