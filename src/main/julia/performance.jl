struct Coordinate
    row::Int
    hole::Int
end

function get_possible_moves(co::Coordinate, row_count)
    moves = Move[]
    co.row >= 3 && co.hole >= 3          && push!(moves, Move(co, Coordinate(co.row - 1, co.hole - 1), Coordinate(co.row - 2, co.hole - 2)))
    co.row >= 3 && co.row - co.hole >= 2 && push!(moves, Move(co, Coordinate(co.row - 1, co.hole), Coordinate(co.row - 2, co.hole)))
    co.hole >= 3                         && push!(moves, Move(co, Coordinate(co.row, co.hole - 1), Coordinate(co.row, co.hole - 2)))
    co.row - co.hole >= 2                && push!(moves, Move(co, Coordinate(co.row, co.hole + 1), Coordinate(co.row, co.hole + 2)))
    row_count - co.row >= 2              && (push!(moves, Move(co, Coordinate(co.row + 1, co.hole), Coordinate(co.row + 2, co.hole))),
                                            push!(moves, Move(co, Coordinate(co.row + 1, co.hole + 1), Coordinate(co.row + 2, co.hole + 2))))
    moves
end

struct Move
    fromh::Coordinate
    jumped::Coordinate
    to::Coordinate
end

mutable struct GameState
    rows::Int
    empty_hole::Coordinate
    occupied_holes::Vector{Coordinate}
end

function init!(gs::GameState)
    for row in 1:gs.rows, hole in 1:row
        (gs.empty_hole.row == row && gs.empty_hole.hole == hole) || push!(gs.occupied_holes, Coordinate(row, hole))
    end
end

function get_legal_moves(gs::GameState)
    legal_moves = Move[]
    @inbounds for co in gs.occupied_holes
        moves = get_possible_moves(co, gs.rows)
        for move in moves
            contains_jumped = move.jumped in gs.occupied_holes
            contains_to = move.to in gs.occupied_holes
            contains_jumped && !contains_to && push!(legal_moves, move)  
        end
    end
    legal_moves
end

function apply_move(gs::GameState, move::Move)
    new_gs = GameState(gs.rows, gs.empty_hole, gs.occupied_holes)

    new_gs.occupied_holes = new_gs.occupied_holes[new_gs.occupied_holes .!= [move.fromh]]
    new_gs.occupied_holes = new_gs.occupied_holes[new_gs.occupied_holes .!= [move.jumped]]
    
    push!(new_gs.occupied_holes, move.to)
    new_gs
end

mutable struct GameCounter
    games_played::Int
    games_solution::Vector{Move}
end


function search(gs::GameState, gc::GameCounter, move_stack::Vector{Move})
    if length(gs.occupied_holes) == 1
        gc.games_played += 1
        append!(gc.games_solution, move_stack)
        return
    end
    legal_moves = get_legal_moves(gs)
    
    if length(legal_moves) == 0
        gc.games_played += 1
        return
    end
    
    for move in legal_moves
        new_gs = apply_move(gs, move)
        push!(move_stack, move)
        search(new_gs, gc, move_stack)
        pop!(move_stack)
    end
end

gs = GameState(5, Coordinate(3, 2), [])
gc = GameCounter(0, Move[])
init!(gs)

@time search(gs, gc, Move[])