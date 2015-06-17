fn RotatePivotOnly obj=
(
	rot = (angleaxis 90 [1,0,0]) as quat
	obj.objectoffsetrot*=rot
	obj.objectoffsetpos*=rot
)

fn GetPositionKeys obj =
(
	keys = #()
/*	if (hasProperty obj.position.controller "keys") then*/
	(
		akeys = obj.position.controller.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.position.controller "x_position") then
	(
		akeys = obj.position.controller.x_position.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.rotation.controller "y_position") then
	(
		akeys = obj.position.controller.y_position.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.position.controller "z_position") then
	(
		akeys = obj.position.controller.z_position.keys
		for k in akeys do appendIfUnique keys k.time
	)
	return keys;
)

fn GetRotationKeys obj =
(
	keys = #()
/*	if (hasProperty obj.rotation.controller "keys") then*/
	(
		akeys = obj.rotation.controller.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.rotation.controller "x_rotation") then
	(
		akeys = obj.rotation.controller.x_rotation.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.rotation.controller "y_rotation") then
	(
		akeys = obj.rotation.controller.y_rotation.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.rotation.controller "z_rotation") then
	(
		akeys = obj.rotation.controller.z_rotation.keys
		for k in akeys do	appendIfUnique keys k.time
	)
	return keys;
)

fn GetScaleKeys obj =
(
	keys = #()
/*	if (hasProperty obj.rotation.controller "keys") then*/
	(
		akeys = obj.scale.controller.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.scale.controller "x_scale") then
	(
		akeys = obj.scale.controller.x_scale.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.scale.controller "y_scale") then
	(
		akeys = obj.scale.controller.y_scale.keys
		for k in akeys do appendIfUnique keys k.time
	)
	if (hasProperty obj.scale.controller "z_scale") then
	(
		akeys = obj.scale.controller.z_scale.keys
		for k in akeys do	appendIfUnique keys k.time
	)
	return keys;
)

fn FixChildPosition obj =
(
	rot = (angleaxis 90 [1,0,0]) as quat
	
	keys = GetPositionKeys(obj)
	
	if keys.count > 0 then
	(
		with animate on 
		(
			for k in keys do
			(
				at time k in coordsys parent obj.position *= rot
			)
		)
	)
	else
	(
		animate off in coordsys parent obj.position *= rot
	)
)

fn FixChildRotation obj =
(
	rot = (angleaxis -90 [1,0,0]) as quat
	
	keys = GetRotationKeys(obj)
	
	if keys.count > 0 then
	(
		with animate on 
		(
			for k in keys do
			(
				at time k in coordsys parent rotate obj rot
			)
		)
	)
	else
	(
		animate off in coordsys parent rotate obj rot
	)
)

fn FixChildrenTransform obj = 
(
	for child in obj.children do
	(
		FixChildPosition(child)
		FixChildRotation(child)
	)
)

fn UpdateScale obj = 
(
	keys = GetScaleKeys(obj)
	
	if keys.count > 0 then
	(
		with animate on 
		(
			for k in keys do
			(
				at time k in coordsys local (
					scale = obj.scale
					obj.scale = [scale.x, scale.z, scale.y]
				)
			)
		)
	)
	else
	(
		animate off in coordsys local (
			scale = obj.scale
			obj.scale = [scale.x, scale.z, scale.y]
		)
	)
)

fn RotateObject obj =
(
	rot = (angleaxis 90 [1,0,0]) as quat
	keys = GetRotationKeys(obj)
	
	if keys.count > 0 then
	(
		with animate on 
		(
			for k in keys do
			(
				at time k in coordsys local obj.rotation*=rot
			)
		)
	)
	else
	(
		animate off in coordsys local obj.rotation*=rot
	)
	FixChildrenTransform(obj)
	UpdateScale(obj)
)

fn UpdateSkin obj =
(
	skin = obj.modifiers["skin"]
	if (skin != undefined) then
	(
		at time 0 skin.always_deform = false
		at time 0 skin.always_deform = true
	)
)

fn ExportSelected =
(
	objs =  selection

	theHold.Cancel() 
	theHold.Begin() 

	for a in objs do
	(
		RotatePivotOnly a
		RotateObject a
		UpdateSkin a
	)

	/*theHold.Accept "Rotate Pivot" */

	actionMan.executeAction 0 "40373"

	theHold.Cancel() 

	for a in objs do
	(
		UpdateSkin a
	)
)

fn ExportAll =
(
	objs =  $*

	theHold.Cancel() 
	theHold.Begin() 

	for a in objs do
	(
		RotatePivotOnly a
		RotateObject a
		UpdateSkin a
	)

	/*theHold.Accept "Rotate Pivot" */

	actionMan.executeAction 0 "40011"

	theHold.Cancel() 

	for a in objs do
	(
		UpdateSkin a
	)
)

macroscript ExportSelected
category: "AlternativaPlatform"
tooltip: "Export Selected To Unity"
(
	on execute do
	(
		If $ == undefined then
		(
			Messagebox "Nothing is selected"
		)
		else
		(
			ExportSelected()
		)
	)
)

macroscript ExportAll
category: "AlternativaPlatform"
tooltip: "Export All To Unity"
(
	on execute do
	(
		ExportAll()
	)
)
