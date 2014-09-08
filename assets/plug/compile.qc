
$modelname "videogames\smes_plug.mdl"
$model "body" "plug.smd"
$cdmaterials "videogames"

// Model uses material "snes_port.vmt"
$surfaceprop "computer"
$staticprop

$sequence idle "idle"
$collisionmodel "phymodel.smd" {

	$concave
	$mass 0.3
	$inertia 1.00
	$damping 0.00
	$rotdamping 0.00
}
