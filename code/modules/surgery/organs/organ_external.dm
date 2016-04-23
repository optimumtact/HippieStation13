/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	var/state_flags = ORGAN_FINE

//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	desc = "This is plenty gruesome isn't it."
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/bloodloss = 0
	var/max_bloodloss = 2
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/human_gender = ""
	var/species_id = ""
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/species_color = ""

/obj/item/organ/limb/proc/update_limb(mob/reference as mob)
	if(!istype(reference))
		var/mob/living/carbon/human/H = loc
		if(istype(H) && locate(src) in H.organs)
			reference = H
	var/mob/living/carbon/human/H = reference
	if(skin_tone == "")
		if(istype(H))
			skin_tone = H.skin_tone
		else
			skin_tone = "caucasian1"
		should_draw_greyscale = TRUE
	if(human_gender == "")
		should_draw_gender = TRUE
		if(istype(H))
			human_gender = H.gender
		else
			human_gender = MALE
	if(istype(H) && H.dna && H.dna.species)
		var/datum/species/S = H.dna.species
		species_id = S.id
		if(MUTCOLORS in S.specflags)
			species_color = H.dna.features["mcolor"]
			should_draw_greyscale = TRUE
		should_draw_gender = S.sexes
	update_icon()

//Similar to human's update_icon proc
/obj/item/organ/limb/update_icon()
	overlays.Cut()
	var/image/I

	if((body_part == HEAD || body_part == CHEST))
		should_draw_gender = TRUE
	else
		should_draw_gender = FALSE

	if(status == ORGAN_ORGANIC)
		if(should_draw_greyscale)
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[species_id]_[Bodypart2name(body_part)]_[human_gender]_s", "layer"=-BODYPARTS_LAYER)
			else
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[species_id]_[Bodypart2name(body_part)]_s", "layer"=-BODYPARTS_LAYER)
		else
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[species_id]_[Bodypart2name(body_part)]_[human_gender]_s", "layer"=-BODYPARTS_LAYER)
			else
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[species_id]_[Bodypart2name(body_part)]_s", "layer"=-BODYPARTS_LAYER)
	else
		if(should_draw_gender)
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[Bodypart2name(body_part)]_[human_gender]_s", "layer"=-BODYPARTS_LAYER)
		else
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[Bodypart2name(body_part)]_s", "layer"=-BODYPARTS_LAYER)
		if(I)
			overlays += I
			return I
		return 0


	if(!should_draw_greyscale)
		if(I)
			overlays += I
			return I //We're done here
		return 0


	//Greyscale Colouring
	var/draw_color

	if(skin_tone) //Limb has skin color variable defined, use it
		draw_color = skintone2hex(skin_tone)
	if(species_color)
		draw_color = species_color

	if(draw_color)
		I.color = "#[draw_color]"
	//End Greyscale Colouring

	if(I)
		overlays += I
		return I
	return 0

/obj/item/organ/limb/chest
	name = "chest"
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST

/obj/item/organ/limb/head
	name = "head"
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
	var/list/teeth_list = list() //Teeth are added in carbon/human/New()
	var/max_teeth = 32 //Changed based on teeth type the species spawns with
	var/max_dentals = 1
	var/list/dentals = list() //Dentals - pills inserted into teeth. I'd die trying to keep track of these for every single tooth.

/obj/item/organ/limb/head/proc/get_teeth() //returns collective amount of teeth
	var/amt = 0
	if(!teeth_list) teeth_list = list()
	for(var/obj/item/stack/teeth in teeth_list)
		amt += teeth.amount
	return amt

/obj/item/organ/limb/head/proc/knock_out_teeth(throw_dir, num=32) //Won't support knocking teeth out of a dismembered head or anything like that yet.
	num = Clamp(num, 1, 32)
	var/done = 0
	if(teeth_list && teeth_list.len) //We still have teeth
		var/stacks = rand(1,3)
		for(var/curr = 1 to stacks) //Random amount of teeth stacks
			var/obj/item/stack/teeth/teeth = pick(teeth_list)
			if(!teeth || teeth.zero_amount()) return //No teeth left, abort!
			var/drop = round(min(teeth.amount, num)/stacks) //Calculate the amount of teeth in the stack
			var/obj/item/stack/teeth/T = new teeth.type(owner.loc, drop)
			T.copy_evidences(teeth)
			teeth.use(drop)
			T.add_blood(owner)
			var/turf/target = get_turf(owner.loc)
			var/range = rand(2,T.throw_range)
			for(var/i = 1; i < range; i++)
				var/turf/new_turf = get_step(target, throw_dir)
				target = new_turf
				if(new_turf.density)
					break
			T.throw_at(target,T.throw_range,T.throw_speed)
			teeth.zero_amount() //Try to delete the teeth
			done = 1
	return done

/obj/item/organ/limb/l_arm
	name = "left arm"
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT


/obj/item/organ/limb/l_leg
	name = "left leg"
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT


/obj/item/organ/limb/r_arm
	name = "right arm"
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT


/obj/item/organ/limb/r_leg
	name = "right leg"
	icon_state = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn, bleed)
	if(owner && (owner.status_flags & GODMODE))	return 0
	brute	= max(brute,0)
	burn	= max(burn,0)
	bleed = max(bleed,0)
	if(status == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)
		bleed = 0 //Robotic limbs don't bleed, stupid!

	bloodloss = min(bloodloss + bleed, max_bloodloss)
	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)	return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	return update_organ_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/organ/limb/proc/heal_damage(brute, burn, bleed, robotic)

	if(robotic && status != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && status == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	bloodloss	= max(bloodloss - bleed, 0)
	return update_organ_icon()


//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(status == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName()
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return name


//Remove all embedded objects from all limbs on the human mob
/mob/living/carbon/human/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.loc = T

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			return 1
