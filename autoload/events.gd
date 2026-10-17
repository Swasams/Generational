extends Node
## Global signal bus. Systems talk through these signals so no script needs a
## direct reference to another system's nodes.

## A tap/click landed on open ground (world coordinates).
signal ground_clicked(world_position: Vector2)
## A tap/click landed on a villager.
signal villager_clicked(villager: Node2D)
## The player walked into a cave exit.
signal cave_exit_entered(overlord: OverlordData)
## The player chose "No" on the leave-village popup.
signal cave_travel_declined()
## The player chose "Yes" on the leave-village popup.
signal cave_travel_confirmed(overlord: OverlordData)
## The top-right stats box was tapped; toggles the stats panel.
signal stats_box_clicked()
## The player walked into a training station's zone.
signal station_entered(station: StationData, station_position: Vector2)
## A year of training finished; summary is the text shown in the result popup.
signal training_completed(station: StationData, summary: String)
## A villager said a talk line (drives their speech bubble).
signal villager_spoke(villager_id: StringName, line: String)
## The Talk/Gift menu opened for a villager (they stop wandering).
signal villager_menu_opened(villager: Node2D)
## The Talk/Gift menu closed.
signal villager_menu_closed()
