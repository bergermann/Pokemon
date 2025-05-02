

# function itemBattleActionBerries!(game::GameState)
#     if game.ctrl.input.choice.sel == 1
#         return
#     elseif game.ctrl.input.choice.sel == 2
#         return
#     end
    
#     resetChoice!(game)

#     return
# end

# function itemBattleActionKeys!(game::GameState)    
#     resetChoice!(game)

#     return
# end



# function applyItem!(game::GameState)
#     item = getItem(getInvSlotID(game))
#     target = game.p.pokemon[game.ctrl.input.battlebags.subslot]

#     applyItem!(target,item)

#     return
# end



# function applyItem!(target::Pkmn,item::MedicineHealth)
#     if !checkItemApplicable(target,item)
#         return
#     end

#     if target.status == 0x07
#         target.stats.rv[1] = floor(UInt16,target.stats.hp*item.amount/100)
#         target.status = 0x00

#         return
#     end

#     (target.status == target.item || item.status == 0x06) &&
#         (target.status = 0x00)
    
#     target.stats.rv[1] = max(target.hp,target.stats.rv[1] + (item.fraction ? 
#         floor(UInt16,target.stats.hp*item.amount/100) : item.amount))

#     return
# end

# function checkItemApplicable(target::Pkmn,item::MedicineHealth)
#     if target.status == 0x07
#         return item.status == 0x07
#     elseif item.status != 0 && item.amount == 0
#         return target.status == item.status || item.status == 0x06
#     elseif item.status != 0 && item.amount != 0
#         return target.status == item.status || item.status == 0x06 ||
#             target.stats.hp != target.stats.rv[1]
#     else
#         return target.stats.hp != target.stats.rv[1]
#     end

#     return
# end