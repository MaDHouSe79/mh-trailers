local Translations = {
    notify = {
        ['already_on_trailer'] = "Dit voertuig staat al op de trailer",
        ['vehicle_must_be_stationary'] = "Het voertuig moet stil staan",
        ['return_wrong_vehicle'] = "Dit is niet het juiste voertuig om terug te brengen!",
        ['not_enough_money_to_rent'] = "Je hebt niet genoeg geld om een iets te huren!",
        ['return_vehicle_popup'] = "Park Vehicle",
    },
    target = {
        ["get_in"] = "Stap in",
        ["ramp_up"] = "Ramp Omhoog",
        ["ramp_down"] = "Ramp Omlaag",
        ["platform_up"] = "Platform Omhoog",
        ["platform_down"] = "Platform Omlaag",
        ["place_ramp"] = "Plaats Ramp",
        ["remove_ramp"] = "Verwijder Ramp",
        ["lock_trailer"] = "Vergrendel Trailer",
        ["unlock_trailer"] = "Ontgrendel Trailer",
        ['rent_a_vehicle'] = "Huur een tuck en trailer",
    },
    info = {
        ['press_boat_message'] = "Druk [%{key}] om de boot vast te zetten",
        ['press_other_message'] = "Druk [%{key}] om het voertuig vast te zetten",
        ['press_to_park'] = "Druk [%{key}] om het voertuig te parkeren",
    },
    menu = {
        ['select_header'] = "Kies een truck en trailer",
        ['select_truck'] = "Selecteer vrachtwagen",
        ['select_trailer'] = "Selecteer Aanhanger",
        ['truck'] = "Vrachtauto",
        ['trailer'] = "Aanhanger",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})