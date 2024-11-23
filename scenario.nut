/*
 *  "Berlin 1961 - 'Simutrans-Player, tear down this wall!'" scenario
 *
 *  tested with nightly r7332, pak128 r1486  and addon berlin1961_v03.pak
 *  Can NOT be used in network game !
 */


 // persistent.bankrupt <- false in resume entfernen

const version = 2                  // version of script = one less then version
map.file = "berlin_1961_v03.sve"   // specify the savegame to load

scenario.short_description = "Berlin 1961 - 'Simutrans-Player, tear down this wall!'"                     // short description to be shown in finance window and in standard implementation of get_about_text
scenario.author = "ny911 (scripting by ny911)"                     // author of map and script
scenario.version = "0." + (version + 1)                            // make a version number
scenario.translation <- "en=ny911, de=ny911"                       // list of translation authors
scenario.addon <- "Dennosius, Gauthier, Propermike, Patrick & mEGa, Vladimir Slavik, Raven, ny911"   // list of addon authors
scenario.addon+= "<br><br><em>Addon graffiti:</em> Tazze, Dennosius, Fabio & mEGa, TZ, Konemaster, ny911"    // List of graffiti painter

startcash <- [ 5, 8, 2, 2, 2 ]     // startcash in million for player HUMAN, PUPLIC, UNESCO, NVA, GRAFFITI
const traffic_level = 10           // level for puplic road traffic

// part one of scenario
revolution   <- { year = 1989, month = 11}   // date of revolution as it was
target_one   <- 200000                       // amont of protesters needed for revolution
brand_tor    <- { x = 546, y = 507, z = -2, happy = 100, text = "Brandenburger Gate" }
zone <- {
         Friedrichstr  = { x = 557, y = 490, z = -2, departed = 50000}  // 50000 okay, gives 300+
         Oberbaumbr    = { x = 674, y = 547, z = -2, departed = 2500}
         Sonnenallee   = { x = 735, y = 669, z = -2, departed = 1500}
         Waltersdorfer = { x = 804, y = 863, z = -2, departed = 1500}
         DreiLinden    = { x = 141, y = 860, z = -2, departed = 500}
         Heerstrasse   = { x = 110, y = 474, z = -2, departed = 500}    // 750 akay, gives 25-50
         Heiligensee   = { x = 252, y = 147, z = -2, departed = 250}    // 250 okay, gives
         Bormholmer    = { x = 579, y = 439, z = -2, departed = 3000}
         Chauseestr    = { x = 550, y = 446, z = -2, departed = 2500}
         Invalidenstr  = { x = 536, y = 467, z = -2, departed = 2000}
         Checkpoint_C  = { x = 557, y = 540, z = -2, departed = 4000}   // 5000 okay, gives 200-250
         Prinzenstr    = { x = 602, y = 543, z = -2, departed = 2500}
        }
// help calc:
// BUS: 2*140 Pegaso-Seida_5020_Urban * 80pax = 22400 max. departed for each
// Train: 2*36 D-Triebwagen VT98 * 640pax = 46080
// for friedrichstr = 2*46080+22400 = 114560 max.

// part two of scenario
headquarter_area <- { x1 = 526, y1 = 487, x2 = 531, y2 = 492 }
wall_museum      <- [ { x = 576, y = 440, z = -2 }, { x = 579, y = 443, z = -2 } ]
min_wall_delete  <- 1100*4        // minimum delete Hits to tear down the wall
tax_rate         <- 10            // tax percentage of income
places <- {
     hbf      = { x = 525, y = 473, z = -2, departed =200000, text = "New Grand Central Train Station" }
     airport  = { x = 803, y = 899, z = -2, departed = 60000, text = "New Int. Airport Berlin" }
     airhelp  = { x = 555, y = 616, z = -3, happy    =  1000, text = "Square air bridge" }
     stasi    = { x = 767, y = 438, z = -2, happy    =  1000, text = "Stasi Jail" }
     stadium  = { x = 275, y = 487, z = -3, happy    = 12000, text = "Olympic stadium" }
     zitadelle= { x = 234, y = 420, z = -2, happy    =   750, text = "Zitadelle" }
     castle_1 = { x = 386, y = 488, z = -2, happy    =  6000, text = "Castle Charlottenburg" }
     castle_2 = { x =   6, y = 852, z = -2, happy    =  1000, text = "Castle Sansouci" }
     trade    = { x = 356, y = 546, z = -3, happy    =  1000, text = "Trade fair area" }
     eastparl = { x = 594, y = 504, z = -3, happy    =  1000, text = "Old Parlament" }
          }

// part three of scenario
target_three <- 95                 // target rate for mail and post service
target_three_city <- {x=603,y=473} // city to used for service


persistent.version <- version      // stores version of script
persistent.citizen <- 0            // stores citizens at startgame time
persistent.bankrupt <- false       // stores bankrupt; changes only one time
persistent.counter <- 0            // stores the loops in each month
persistent.last_month <- -1        // stores lastmonth default -1
persistent.protesters <- 0         // stores amount of unhappy people
persistent.stasi <- 0              // stores protesters captured by stasi
persistent.level <- 1              // stores level/part of the scenario
persistent.tax <- 0                // stores the tax
persistent.extra_tax <- 0          // stores delay of revolution in month
persistent.last_payed <- 0         // stores the last month tax
persistent.wall_delete <- 0        // stores hits to delete wall
persistent.wall_map <- {}          // stores removed wall x,y place


forbid_tools_list <-{
      berlin_wall = {              // protect the Berlin wall
             modus = "rect",
             waytyp= wt_all,
             tools = [ tool_build_way, tool_build_bridge, tool_build_tunnel, tool_remover, tool_remove_way, tool_build_depot, tool_build_station, tool_build_wayobj, tool_build_roadsign ],
             error = ["no action at the wall",
                      "no action at the wall",
                      "defend the wall undergound",
                      "defend the wall",
                      "defend the wall",
                      "no action at the wall",
                      "no action at the wall",
                      "no action at the wall",
                      "no action at the wall"
                     ],
             list  = [
                       // open part
                       [ {x = 527, y = 297}, {x = 530, y = 340} ],
                       // open part
                       [ {x = 570, y = 378}, {x = 572, y = 383} ],
                       [ {x = 573, y = 381}, {x = 575, y = 386} ],
                       [ {x = 555, y = 445}, {x = 557, y = 452} ],  // Zone - Bormholmer Strasse
                       [ {x = 558, y = 448}, {x = 560, y = 455} ],
                       [ {x = 561, y = 453}, {x = 572, y = 456} ],
                       [ {x = 569, y = 447}, {x = 576, y = 452} ],
                       [ {x = 576, y = 385}, {x = 579, y = 448} ],
                       [ {x = 540, y = 443}, {x = 554, y = 446} ],  // Zone - Berlin Mitte
                       [ {x = 536, y = 443}, {x = 539, y = 484} ],
                       [ {x = 536, y = 485}, {x = 540, y = 491} ],
                       [ {x = 541, y = 487}, {x = 544, y = 496} ],
                       [ {x = 541, y = 497}, {x = 546, y = 500} ],
                       [ {x = 547, y = 497}, {x = 550, y = 530} ],
                       [ {x = 543, y = 527}, {x = 547, y = 540} ],
                       [ {x = 548, y = 537}, {x = 602, y = 540} ],
                       [ {x = 599, y = 541}, {x = 602, y = 549} ],
                       [ {x = 603, y = 546}, {x = 623, y = 549} ],
                       [ {x = 620, y = 531}, {x = 623, y = 545} ],
                       [ {x = 624, y = 531}, {x = 650, y = 534} ],
                       [ {x = 651, y = 533}, {x = 655, y = 539} ],
                       [ {x = 654, y = 539}, {x = 666, y = 544} ],  // Zone - Oberbaumbrücke
                       [ {x = 666, y = 543}, {x = 679, y = 547} ],
                       [ {x = 676, y = 543}, {x = 679, y = 576} ],
                       [ {x = 665, y = 577}, {x = 679, y = 579} ],
                       [ {x = 665, y = 577}, {x = 667, y = 592} ],
                       [ {x = 668, y = 589}, {x = 686, y = 592} ],
                       [ {x = 683, y = 593}, {x = 686, y = 601} ],
                       [ {x = 687, y = 598}, {x = 708, y = 601} ],
                       // open part
                       [ {x = 732, y = 643}, {x = 735, y = 681} ],  // Zone - Sonnenallee
                       [ {x = 693, y = 677}, {x = 731, y = 681} ],
                       // open part
                       [ {x = 736, y = 860}, {x = 814, y = 863} ],  // Zone - Waltersdorfer Chausee
                       [ {x = 811, y = 772}, {x = 814, y = 859} ],
                       // open part
                       [ {x = 249, y = 133}, {x = 252, y = 165} ],  // Zone - Heiligensee
                       [ {x = 249, y = 133}, {x = 329, y = 136} ],
                       // open part
                       [ {x = 107, y = 352}, {x = 110, y = 500} ],  // Zone - Heerstraße
                       // open part
                       [ {x = 138, y = 849}, {x = 141, y = 883} ],  // Zone - Drei Linden
                       [ {x =  87, y = 880}, {x = 137, y = 883} ]
                       // open part
                     ]
                     }
      water_wall = {                // protect water at the wall
             modus = "rect",
             waytyp= wt_all,
             tools = [ tool_raise_land, tool_setslope],
             error = ["No terraforming allowed at the border.",
                      "No terraforming allowed at the border."
                     ],
             list  = [
                       [ {x = 732, y = 676}, {x = 735, y = 678} ],
                       [ {x = 535, y = 463}, {x = 538, y = 470} ],
                       [ {x = 536, y = 479}, {x = 539, y = 484} ],
                       [ {x = 676, y = 545}, {x = 679, y = 568} ]
                     ]
                     }
      zone_roads = {              // protect the one field road or track bevor zone stop !!! Takes game playable !
             modus = "cube",
             waytyp= wt_all,
             tools = [ tool_remover, tool_remove_way ],
             error = ["Do not remove the way near the wall stations.",
                      "Do not remove the way near the wall stations."
                     ],
             list  = [
                       [ {x = 674, y = 542, z = -2}, {x = 674, y = 553, z = -2} ],  // Zone - oberbaumbrücke
                       [ {x = 598, y = 543, z = -2}, {x = 603, y = 543, z = -2} ],
                       [ {x = 557, y = 536, z = -2}, {x = 557, y = 541, z = -2} ],
                       [ {x = 543, y = 467, z = -2}, {x = 540, y = 467, z = -2} ],
                       [ {x = 550, y = 442, z = -2}, {x = 550, y = 442, z = -2} ],  // Zone - Chauseestrasse
                       [ {x = 575, y = 439, z = -2}, {x = 580, y = 439, z = -2} ],
                       // add more here
                       [ {x = 531, y = 476, z =  0}, {x = 540, y = 479, z = -2} ],  // elevated bridge two level
                       [ {x = 102, y = 412, z = -2}, {x = 115, y = 413, z = -2} ],  // Zone - Spandau (transit)
                       [ {x = 105, y = 875, z = -2}, {x = 106, y = 888, z = -2} ]   // Zone - Wannsee (transit)
                     ]
                     }
      }       // end of forbit_tools_list
// END of declarations




function start()
{
        for (local i=0; i<startcash.len();i++)   // set start cash for players
            {
             while ( player_x(i).get_cash()[0] < 0)
                   { player_x(i).book_cash(5000000) }
             local cash = (startcash[i] * 1000000) - player_x(i).get_cash()[0]
             if (i > 0) cash--
             player_x(i).book_cash( cash * 100 )
            }
        persistent.citizen = world.get_citizens()[0]
        forbid_tools(0, forbid_tools_list)
        resume_game()
}


function get_about_text(pl)
{
        local about = ttextfile("about.txt")
        about.short_description =  scenario.short_description
        about.version =  scenario.version
        about.author =  scenario.author
        about.translation = scenario.translation
        about.addon = scenario.addon
        return about
}


function get_info_text(pl)
{
        local info = ttextfile("info_"+persistent.level+".txt")
        if (persistent.level == 1)
           {
            info.startyear = settings.get_start_time().year
            info.citizen = integer_to_string(persistent.citizen)
            info.startcash =  money_to_string(startcash[0] * 1000000)
            info.factories = world.get_factories()[0]   // well, that's the current amount
            info.towns = world.get_towns()[0]           // well, that's the current amount
           }
        if (persistent.level == 2)
           {
            info.salestax = tax_rate
           }
        return info
}


function get_rule_text(pl)
{
        local rule = ttextfile("rule_"+persistent.level+".txt")
        local help = ttextfile("rule_4.txt")
        return rule.tostring() + help.tostring()
}


function get_goal_text(pl)
{
        local goal = ttextfile("goal_"+persistent.level+".txt")
        local help = ""
        if (persistent.level == 1)
           {
            foreach (key,point in zone)
               {
                local halt = tile_x( point.x, point.y, point.z ).get_halt()
                if (halt == null)
                     { halt = key }
                else { halt = halt.get_name() }
                help+= "(" + point.x + "," + point.y + ") "
                help+= "<a href\"("+point.x+","+point.y+")\">"+halt+"</a> "
                help+= ttext("departed") + " = " + point.departed
                help+= "<br>"
               }
            goal.zonen = help
            goal.target_one = integer_to_string(target_one)
            goal.brand_happy = brand_tor.happy
            goal.revolution_date = get_month_name(revolution.month) + " " + revolution.year
           }
        if (persistent.level == 2)
           {
            foreach (p in places)
               {
                help+= "(" + p.x + "," + p.y + "," + p.z + ") "
                help+= "<a href\"("+p.x+","+p.y+")\">"+ttext(p.text)+"</a> "
                help+= ("departed" in p)?(ttext("departed")+" = "+p.departed):(ttext("happy")+" = "+p.happy)
                help+= "<br>"
               }
            goal.places = help
            goal.soli_rate = tax_rate
            goal.revolution_date = get_month_name(revolution.month) + " " + revolution.year
           }
        if (persistent.level == 3)
           {
            local help = city_x(target_three_city.x,target_three_city.y).get_name()
            goal.target_three_city = "<a href=\"("+target_three_city.x+","+target_three_city.y+")\">"+help+"</a>"
            goal.target_three = target_three
           }
        return goal
}


function get_result_text(pl)
{
        if (persistent.bankrupt)
           { return ttext("<st>You lost!</st><br><br>You are bankrupt.") }
        local result = ttextfile("result_"+persistent.level+".txt")
        result.result = give_percentage(persistent.level,pl)
        if (persistent.level == 1)
           {
            result.protesters = integer_to_string(persistent.protesters)
            result.stasi_count = integer_to_string(persistent.stasi)
            local month = world.get_time().month - 1
            local year = world.get_time().year
            if (month < 0)
               {
                month = 11
                year--
               }
            result.date = get_month_name(month)+" "+year
            result.transit = visit_transit(pl)?
                 ttext("Your trains make the necessary stop at each tranist stations."):
                 ttext("Your trains didn't stop at the tranist stations.")
           }
        if (persistent.level == 2)
           {
            result.soli_rate = 10
            local help = ""
            foreach (p in places)
              {
               local halt = tile_x( p.x, p.y, p.z ).get_halt()
               help+= "<a href\"("+p.x+","+p.y+")\">"+ttext(p.text)+"</a> "
               if (!(halt == null))
                   {
                    help+= ("departed" in p)?(ttext("departed")+" = "):(ttext("happy")+" = ")
                    local h2 = ("departed" in p)?
                         (halt.get_departed().reduce(sum)+"/"+p.departed):
                         (halt.get_happy().reduce(sum)+"/"+p.happy)
                    if (halt.get_unhappy().reduce(sum) > 0)
                        h2 = "<st>" + h2 + "</st>"
                    help+= h2
                   }
               else
                    help+= "<it>"+ttext("no station build")+"</it>"
               help+= "<br>"
              }
            result.places = help
            switch(hq_level(pl) ) {
                case 0: result.hq_text = ttext("You did not build a luxurious headquarter yet. Go earn more money.")
                        break
                case 1: result.hq_text = ttext("You build only a small headquarter.")
                        break
                case 2: result.hq_text = ttext("You build a luxurious headquarter.")
                        break
               }
            result.payed_tax = money_to_string(persistent.tax)
            result.soli_rate = tax_rate + persistent.extra_tax
            result.wall_delete = min( (persistent.wall_delete*100) / min_wall_delete, 100)     // + " Z:"+ persistent.wall_delete
           }
        if (persistent.level == 3)
           {
            local city = city_x(target_three_city.x,target_three_city.y)
            result.ratio_pax = get_pax_ratio(city)
            result.ratio_mail = get_mail_ratio(city)
           }
        return result
}


function give_percentage(level,pl)
{
        if (level <= 1)     // part one
           {
            return min ( (persistent.protesters * 100) / target_one , 100 )
           }
        if (level == 2)     // part two
           {
            local h1 = 0
            local h2 = 0
            foreach (p in places)
              {
               local halt = tile_x( p.x, p.y, p.z ).get_halt()
               if ("departed" in p)
                    {
                     if (!(halt == null))
                         if (halt.get_unhappy().reduce(sum) == 0)
                         h1+= min( halt.get_departed().reduce(sum), p.departed)
                     h2+= p.departed
                    }
               else {
                     if (!(halt == null))
                         if (halt.get_unhappy().reduce(sum) == 0)
                         h1+= min( halt.get_happy().reduce(sum), p.happy)
                     h2+= p.happy
                    }
              }
            // add hits of tear down the wall
            h1+= min (persistent.wall_delete, min_wall_delete) * 50
            h2+= min_wall_delete * 50
            // headquarter build gives 100.000 points
            if (hq_level(pl) == 2) h1+= 100000
            h2+= 100000
            return min( (h1*100) / h2 , 100)  // calcuate percentage
           }
        if (level == 3)     // part three
           {
            local city = city_x(target_three_city.x,target_three_city.y)
            return min( get_pax_ratio(city), get_mail_ratio(city) )
           }
}


function sum(a,b) { return a+b }


function hq_level(pl)
{
        local level = player_x(pl).get_headquarter_level()
        local pos = player_x(pl).get_headquarter_pos()
        if ( !(pos.x >= 0) ) { level = 0 }
        return level
}


function get_pax_ratio(city)
{
        local pax_generated = city.generated_pax.reduce(sum)
        local pax_transported = city.transported_pax.reduce(sum)
        return (pax_transported*100) / pax_generated
}


function get_mail_ratio(city)
{
        local mail_generated = city.generated_mail.reduce(sum)
        local mail_transported = city.transported_mail.reduce(sum)
        return (mail_transported*100) / mail_generated
}


function pay_tax(pl)
{
        // pay tax for this month; control the income it can be below zero
        persistent.tax = 0
        local income = player_x(pl).get_income()[1]        // vehicle earnings
        income+= player_x(pl).get_powerline()[1]           // powerline earnings
        income+= -persistent.last_payed                    // add last month paying
        if (income < 0) return
        persistent.tax = income * (tax_rate + persistent.extra_tax ) / 100
        player_x(pl).book_cash( persistent.tax * -100)
        persistent.last_payed = player_x(pl).get_income()[0]
        if (persistent.last_payed > 0) { persistent.last_payed = 0 } // needed !!
}


function clear_my_rules(pl)
{
        rules.clear()             // open the wall compelete
        // add wall museum to protect small part of the wall
        local text = ttext("You can't remove the Wall History Museum.")
        rules.forbid_way_tool_cube(pl, tool_remover, wt_all, wall_museum[0], wall_museum[1], text )
        rules.forbid_way_tool_cube(pl, tool_remove_way, wt_all, wall_museum[0], wall_museum[1], text )
        rules.forbid_way_tool_cube(pl, tool_build_way, wt_all, wall_museum[0], wall_museum[1], text )

        scenario.forbidden_tools <- []        // first delete all
        scenario.forbidden_tools = map.editing_tools
}


function visit_transit(pl)
{
       // did player have minimum one stop/month at each transit station
       local halt_1 = tile_x( 109,413,-1 ).get_halt()
       if (! (halt_1 == null))
          if (halt_1.get_convoys().reduce(sum) == 0) return false
       local halt_2 = tile_x( 106,882,-1 ).get_halt()
       if (! (halt_2 == null))
          if (halt_2.get_convoys().reduce(sum) == 0) return false
       return true
}


function do_part_one(pl)
{
       local halt = null
       persistent.protesters-= persistent.stasi  // reduce the protestors
       foreach (point in zone)                   // check the ZONE stations
           {
            halt = tile_x( point.x, point.y, point.z ).get_halt()
            if (! (halt == null))
                   if (halt.get_departed()[1] >= point.departed)
                       persistent.protesters+= halt.get_unhappy()[1]
           }
       // check extra station
       halt = tile_x( brand_tor.x, brand_tor.y, brand_tor.z ).get_halt()
       if (! (halt == null))
           if (halt.get_happy()[1] > brand_tor.happy)
               persistent.protesters+= halt.get_happy()[1] - brand_tor.happy
       // stasi will capture some protestors ( max. 375 + 0,2% )
       persistent.stasi = min(persistent.protesters,  100) * 0.75
       persistent.stasi+= min(persistent.protesters, 1000) * 0.10
       persistent.stasi+= min(persistent.protesters,10000) * 0.02
       if (persistent.protesters > 10000)
          { persistent.stasi+= persistent.protesters * 0.002 }
       persistent.stasi = persistent.stasi.tointeger()
       // give NVA and GRAFFITI players money
       player_x(3).book_cash( ((startcash[3] * 1000000) - player_x(3).get_net_wealth()[0] - 1) * 100 )
       player_x(4).book_cash( ((startcash[4] * 1000000) - player_x(4).get_net_wealth()[0] - 1) * 100 )
       // did we have revolution
       if ( ( (world.get_time().year = revolution.year) && (world.get_time().month >= revolution.month) ||
              (world.get_time().year > revolution.year)
            ) && (persistent.protesters >= target_one) && visit_transit(pl) )
            {
             persistent.level = 2
             city_x(749,405).set_citygrowth_enabled(true)  // city Hohenschöhnhausen
             city_x(373,310).set_citygrowth_enabled(true)  // city Tegel
             clear_my_rules(pl)
             // set NVA and GRAFFITI players bankrott
             player_x(3).book_cash( player_x(3).get_net_wealth()[0] * -110 )
             player_x(4).book_cash( player_x(4).get_net_wealth()[0] * -110 )
             persistent.extra_tax = (world.get_time().year - revolution.year) * 12
             persistent.extra_tax+= world.get_time().month - revolution.month
             local text = ttext("Revolution! Tear down the wall!")
             gui.add_message( text.tostring() )
            }
}


function do_part_two(pl)
{
        pay_tax(pl)
        if (give_percentage(persistent.level,pl) == 100)
           {
            persistent.level = 3
            city_x(558,532).set_citygrowth_enabled(true)  // city Friedrichstadt
            city_x(565,500).set_citygrowth_enabled(true)  // city Ost-Berlin
            city_x(334,605).set_citygrowth_enabled(true)  // city Grunewald
            city_x(  7,838).set_citygrowth_enabled(true)  // city Potsdam
           }
}


function is_scenario_completed(pl)
{
        if (pl != 0) return 0                        // other player get only 0%
        persistent.counter++
        if (persistent.last_month != world.get_time().month)
            {
             persistent.last_month = world.get_time().month
             persistent.counter = 0                  // new month, set counter = 0
             // give other players cash for maintenance
             player_x(1).book_cash( (player_x(1).get_maintenance()[0] - 1) * -100 )
             player_x(2).book_cash( (player_x(2).get_maintenance()[0] - 1) * -100 )
             if (player_x(pl).get_net_wealth()[0] < 0)    // never be bankrupt
                     persistent.bankrupt = true
            }
        if (persistent.bankrupt) { return 0 }        // you lost !!
        if (persistent.counter == 2)
            {
            switch(persistent.level) {               // select the scenario part
                case 1: do_part_one(pl)
                        break
                case 2: do_part_two(pl)
                        break
                case 3: if (give_percentage(persistent.level,pl) == 100)
                           { gui.add_message("You won the scenario!") }
                        break
                }
            }
        return ( give_percentage(persistent.level,pl) + (persistent.level-1) * 100 ) / 3
}


function resume_game()
{
        local pl = 0                                  // player default 0
        if ( !("version" in persistent) ) { persistent.version <- 0 }
        // check for script version and compatibility, then use update
        if ( persistent.version < version ) { update() }
        persistent.version = version

persistent.bankrupt <- false

        revolution.month--                            // we count from zero
        // correct settings of savegame
        settings.set_industry_increase_every(0)       // no industries will be created
        settings.set_traffic_level(traffic_level)     // traffic_level

        // renew for each reload, declaration must be here
        // array for the map editing tools | don't forbid : dialog_edit_house
        map.editing_tools <- [ tool_add_city, tool_change_city_size, tool_land_chain, tool_city_chain,
                       tool_build_factory, tool_link_factory, tool_lock_game, tool_build_cityroad,
                       tool_increase_industry, tool_step_year, tool_fill_trees, tool_set_traffic_level,
                       dialog_edit_factory, dialog_edit_attraction, dialog_edit_tree, dialog_enlarge_map]
        map.editing_tools.append( tool_switch_player )

        rules.forbid_tool(pl, tool_make_stop_public ) // no extra puplic stations in first part
        scenario.forbidden_tools <- map.editing_tools // forbidden tools
        if (persistent.level >= 2) clear_my_rules(pl)
        else scenario.forbidden_tools.append( dialog_edit_house )
        gui.open_info_win()                           // show scenario window
}


function is_work_allowed_here(pl, tool_id, name, pos, tool)
{
        if (tool_id == tool_headquarter){      // headquarter only in allowed area
                if (persistent.level < 2) {
                    return ttext("You can't build your headquarter as long there is a wall in Berlin.")
                   }
                local hq = headquarter_area
                if (pos.x<hq.x1 || hq.x2<pos.x || pos.y<hq.y1 || hq.y2<pos.y) {
                    return ttext("You have to build your headquarter near to the place (529,490).")
                   }
                }
        if (persistent.level == 2 &&           // count each hit, if berlin wall will be removed
           (tool_id == tool_remover || tool_id == tool_remove_way) )
                {
                 if (! ( (pos.x in persistent.wall_map) &&
                       (pos.y in persistent.wall_map[pos.x]) ) )
                 foreach (area in forbid_tools_list.berlin_wall.list)
                      if (! (pos.x<area[0].x || area[1].x<pos.x || pos.y<area[0].y || area[1].y<pos.y) )
                          {
                           persistent.wall_map[pos.x] <- { [pos.y] = 1 }
                           persistent.wall_delete++
                           return null         // make fast exit
                          }
                }
        return null                            // null is equivalent to 'allowed'
}


function forbid_tools(pl, list)
{
        foreach(j in list) {
            if (j.modus == "rect") {
                for (local i=0; i < j.tools.len(); i++) {
                     for (local e=0; e < j.list.len(); e++) {
                         rules.forbid_way_tool_rect(pl, j.tools[i], j.waytyp, "", j.list[e][0], j.list[e][1], ttext(j.error[i]) )
                         }
                     }
               }
            else {
                for (local i=0; i < j.tools.len(); i++) {
                     for (local e=0; e < j.list.len(); e++) {
                         rules.forbid_way_tool_cube(pl, j.tools[i], j.waytyp, "", j.list[e][0], j.list[e][1], ttext(j.error[i]) )
                         }
                     }
               }
           }
}


function update()         // update for older versions
{
 local text = ttext("Savegame has a different {more_info} script version! Maybe, it will work.")
 text.more_info = "(0." + persistent.version + ")"
 gui.add_message( text.tostring() )

 // version 0.2
 // set to old places and numbers
 if (persistent.version = 1) {
	scenario.addon <- "Dennosius, Gauthier, Propermike, Patrick & mEGa, Vladimir Slavik, Raven, ny911"   // list of addon authors
	scenario.addon+= "<br>graffiti: Dennosius, Fabio & mEGa, ny911"    // List of graffiti painter

	startcash <- [ 10, 8, 2, 2, 2 ]    // startcash in million for player HUMAN, PUPLIC, UNESCO, NVA, GRAFFITI
	brand_tor    <- { x = 546, y = 507, z = -1, happy = 100, text = "Brandenburger Gate" }
	zone <- {
	         Friedrichstr  = { x = 557, y = 490, z = -1, departed = 50000}  // 50000 okay, gives 300+
         	 Oberbaumbr    = { x = 674, y = 547, z = -1, departed = 2500}
	         Sonnenallee   = { x = 735, y = 669, z = -1, departed = 1500}
         	 Waltersdorfer = { x = 804, y = 863, z = -1, departed = 1500}
	         DreiLinden    = { x = 141, y = 860, z = -1, departed = 500}
         	 Heerstrasse   = { x = 110, y = 474, z = -1, departed = 500}    // 750 akay, gives 25-50
	         Heiligensee   = { x = 252, y = 147, z = -1, departed = 250}    // 250 okay, gives
	         Bormholmer    = { x = 579, y = 439, z = -1, departed = 3000}
	         Chauseestr    = { x = 550, y = 446, z = -1, departed = 2500}
	         Invalidenstr  = { x = 536, y = 467, z = -1, departed = 2000}
	         Checkpoint_C  = { x = 557, y = 540, z = -1, departed = 4000}   // 5000 okay, gives 200-250
         	 Prinzenstr    = { x = 602, y = 543, z = -1, departed = 2500}
	        }
	// help calc:
	// BUS: 2*140 Pegaso-Seida_5020_Urban * 80pax = 22400 max. departed for each
	// Train: 2*36 D-Triebwagen VT98 * 640pax = 46080
	// for friedrichstr = 2*46080+22400 = 114560 max.

	// part two of scenario
	headquarter_area <- { x1 = 526, y1 = 487, x2 = 531, y2 = 492 }
	wall_museum      <- [ { x = 576, y = 440, z = -1 }, { x = 579, y = 443, z = -1 } ]
	min_wall_delete  <- 1100*4        // minimum delete Hits to tear down the wall
	tax_rate         <- 10            // tax percentage of income
	places <- {
	     hbf      = { x = 525, y = 473, z = -1, departed =200000, text = "New Grand Central Train Station" }
	     airport  = { x = 803, y = 899, z = -1, departed = 60000, text = "New Int. Airport Berlin" }
	     airhelp  = { x = 555, y = 616, z = -2, happy    =  1000, text = "Square air bridge" }
	     stasi    = { x = 767, y = 438, z = -1, happy    =  1000, text = "Stasi Jail" }
	     stadium  = { x = 274, y = 487, z = -2, happy    = 12000, text = "Olympic stadium" }
	     zitadelle= { x = 234, y = 420, z = -1, happy    =   750, text = "Zitadelle" }
	     castle_1 = { x = 386, y = 488, z = -1, happy    =  6000, text = "Castle Charlottenburg" }
	     castle_2 = { x =   6, y = 852, z = -1, happy    =  1000, text = "Castle Sansouci" }
	     trade    = { x = 356, y = 546, z = -2, happy    =  1000, text = "Trade fair area" }
	     eastparl = { x = 594, y = 504, z = -2, happy    =  1000, text = "Old Parlament" }
	          }
forbid_tools_list <-{
      berlin_wall = {              // protect the Berlin wall
             modus = "rect",
             waytyp= wt_all,
             tools = [ tool_build_way, tool_build_bridge, tool_build_tunnel, tool_remover, tool_remove_way, tool_build_depot, tool_build_station, tool_build_wayobj, tool_build_roadsign ],
             error = ["no action at the wall",
                      "no action at the wall",
                      "defend the wall undergound",
                      "defend the wall",
                      "defend the wall",
                      "no action at the wall",
                      "no action at the wall",
                      "no action at the wall",
                      "no action at the wall"
                     ],
             list  = [
                       // open part
                       [ {x = 527, y = 297}, {x = 530, y = 340} ],
                       // open part
                       [ {x = 570, y = 378}, {x = 572, y = 383} ],
                       [ {x = 573, y = 381}, {x = 575, y = 386} ],
                       [ {x = 555, y = 445}, {x = 557, y = 452} ],  // Zone - Bormholmer Strasse
                       [ {x = 558, y = 448}, {x = 560, y = 455} ],
                       [ {x = 561, y = 453}, {x = 572, y = 456} ],
                       [ {x = 569, y = 447}, {x = 576, y = 452} ],
                       [ {x = 576, y = 385}, {x = 579, y = 448} ],
                       [ {x = 540, y = 443}, {x = 554, y = 446} ],  // Zone - Berlin Mitte
                       [ {x = 536, y = 443}, {x = 539, y = 484} ],
                       [ {x = 536, y = 485}, {x = 540, y = 491} ],
                       [ {x = 541, y = 487}, {x = 544, y = 496} ],
                       [ {x = 541, y = 497}, {x = 546, y = 500} ],
                       [ {x = 547, y = 497}, {x = 550, y = 530} ],
                       [ {x = 543, y = 527}, {x = 547, y = 540} ],
                       [ {x = 548, y = 537}, {x = 602, y = 540} ],
                       [ {x = 599, y = 541}, {x = 602, y = 549} ],
                       [ {x = 603, y = 546}, {x = 623, y = 549} ],
                       [ {x = 620, y = 531}, {x = 623, y = 545} ],
                       [ {x = 624, y = 531}, {x = 650, y = 534} ],
                       [ {x = 651, y = 533}, {x = 655, y = 539} ],
                       [ {x = 654, y = 539}, {x = 666, y = 544} ],  // Zone - Oberbaumbrücke
                       [ {x = 666, y = 543}, {x = 679, y = 547} ],
                       [ {x = 676, y = 543}, {x = 679, y = 576} ],
                       [ {x = 665, y = 577}, {x = 679, y = 579} ],
                       [ {x = 665, y = 577}, {x = 667, y = 592} ],
                       [ {x = 668, y = 589}, {x = 686, y = 592} ],
                       [ {x = 683, y = 593}, {x = 686, y = 601} ],
                       [ {x = 687, y = 598}, {x = 708, y = 601} ],
                       // open part
                       [ {x = 732, y = 643}, {x = 735, y = 681} ],  // Zone - Sonnenallee
                       [ {x = 693, y = 677}, {x = 731, y = 681} ],
                       // open part
                       [ {x = 736, y = 860}, {x = 814, y = 863} ],  // Zone - Waltersdorfer Chausee
                       [ {x = 811, y = 772}, {x = 814, y = 859} ],
                       // open part
                       [ {x = 249, y = 133}, {x = 252, y = 165} ],  // Zone - Heiligensee
                       [ {x = 249, y = 133}, {x = 329, y = 136} ],
                       // open part
                       [ {x = 107, y = 352}, {x = 110, y = 500} ],  // Zone - Heerstraße
                       // open part
                       [ {x = 138, y = 849}, {x = 141, y = 883} ],  // Zone - Drei Linden
                       [ {x =  87, y = 880}, {x = 137, y = 883} ]
                       // open part
                     ]
                     }
      water_wall = {                // protect water at the wall
             modus = "rect",
             waytyp= wt_all,
             tools = [ tool_raise_land, tool_setslope],
             error = ["No terraforming allowed at the border.",
                      "No terraforming allowed at the border."
                     ],
             list  = [
                       [ {x = 732, y = 676}, {x = 735, y = 678} ],
                       [ {x = 535, y = 463}, {x = 538, y = 470} ],
                       [ {x = 536, y = 479}, {x = 539, y = 484} ],
                       [ {x = 676, y = 545}, {x = 679, y = 568} ]
                     ]
                     }
      zone_roads = {              // protect the one road or track bevor zone stop !!! Takes game playable !
             modus = "cube",
             waytyp= wt_all,
             tools = [ tool_remover, tool_remove_way ],
             error = ["Do not remove the way near the wall stations.",
                      "Do not remove the way near the wall stations."
                     ],
             list  = [
                       [ {x = 674, y = 542, z = -1}, {x = 674, y = 553, z = -1} ],  // Zone - oberbaumbrücke
                       [ {x = 598, y = 543, z = -1}, {x = 603, y = 543, z = -1} ],
                       [ {x = 557, y = 536, z = -1}, {x = 557, y = 541, z = -1} ],
                       [ {x = 543, y = 467, z = -1}, {x = 540, y = 467, z = -1} ],
                       [ {x = 550, y = 442, z = -1}, {x = 550, y = 442, z = -1} ],  // Zone - Chauseestrasse
                       [ {x = 575, y = 439, z = -1}, {x = 580, y = 439, z = -1} ],
                       // add more here
                       [ {x = 535, y = 476, z =  0}, {x = 540, y = 479, z =  0} ],  // elevated Bridge
                       [ {x = 102, y = 412, z = -1}, {x = 115, y = 413, z = -1} ],  // Zone - Spandau (transit)
                       [ {x = 105, y = 875, z = -1}, {x = 106, y = 888, z = -1} ]   // Zone - Wannsee (transit)
                     ]
                     }
      }       // end of forbit_tools_list
	}
 // end version 0.2

 // version smaller as 0.2
 // do nothing in the moment
}

// END OF FILE
