
$modelname "videogames\smes_console.mdl"
$model "body" "smes.smd"
$cdmaterials "videogames"

// Model uses material "smes_console.vmt"
$surfaceprop "computer"


$sequence idle "idle.smd"
$sequence on "on.smd"
$collisionmodel "phymodel.smd" {

	$concave
	$mass 10.9
	$inertia 1.00
	$damping 0.00
	$rotdamping 0.00
}
