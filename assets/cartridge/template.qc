$modelname "videogames\{{REPLACE}}\cartridge.mdl"
$model "studio" "cart_{{REPLACE}}.smd"
$cdmaterials "videogames\{{REPLACE}}"

$surfaceprop "computer"
$staticprop

$sequence idle "idle.smd"
$collisionmodel "phymodel.smd" {
	$concave
	$mass 1.7
	$inertia 1.00
	$damping 0.00
	$rotdamping 0.00
}
