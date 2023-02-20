local Translations = {
    notify = {
        ['already_on_trailer'] = "This vehicle is already on the trailer",
        ['vehicle_must_be_stationary'] = "The vehicle must be stationary",
        ['return_wrong_vehicle'] = "This is not the right vehicle to return!",
        ['not_enough_money_to_rent'] = "You don't have enough money to rent a thing!",
    },
    target = {
        ["get_in"] = "Get in",
        ["ramp_up"] = "Ramp Up",
        ["ramp_down"] = "Ramp Down",
        ["platform_up"] = "Platform Up",
        ["platform_down"] = "Platform Down",
        ["place_ramp"] = "Place Ramp",
        ["remove_ramp"] = "Remove Ramp",
        ["lock_trailer"] = "Lock Trailer",
        ["unlock_trailer"] = "Unlock Trailer",
        ['rent_a_vehicle'] = "Rent a tuck and trailer",
    },
    info = {
        ['press_boat_message'] = "Press [%{key}] to secure the boat",
        ['press_other_message'] = "Press [%{key}] to secure the vehicle",
        ['press_to_park'] = "Press [%{key}] tp park the vehicle.",
    },
    menu = {
        ['select_header'] = "Select a truck and trailer",
        ['select_truck'] = "Select truck",
        ['select_trailer'] = "Select Trailer",
        ['truck'] = "Truck",
        ['trailer'] = "Trailer",
    },
}
Lang:t('menu.truck')
Lang = Lang or Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})