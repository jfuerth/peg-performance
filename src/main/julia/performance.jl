struct Coordinate
    row::Int
    hole::Int
    
    function Coordinate(row, hole)
        hole < 1   && throw(error("Illegal hole number"))
        hole > row && throw(error("Illegal hole number"))
        new(row, hole)
    end
end

@inline function get_possible_moves(co::Coordinate, row_count::Int)::Vector{Move}
    moves = Vector{Move}(undef, 0)
    if co.row >= 3
        if co.hole >= 3
            push!(moves, Move(co, Coordinate(co.row - 1, co.hole - 1), Coordinate(co.row - 2, co.hole - 2)))
        end
        if co.row - co.hole >= 2
            push!(moves, Move(co, Coordinate(co.row - 1, co.hole), Coordinate(co.row - 2, co.hole)))
        end
    end
    if co.hole >= 3
        push!(moves, Move(co, Coordinate(co.row, co.hole - 1), Coordinate(co.row, co.hole - 2)))
    end
    if co.row - co.hole >= 2
        push!(moves, Move(co, Coordinate(co.row, co.hole + 1), Coordinate(co.row, co.hole + 2)))
    end
    if row_count - co.row >= 2
        push!(moves, Move(co, Coordinate(co.row + 1, co.hole), Coordinate(co.row + 2, co.hole)))
        push!(moves, Move(co, Coordinate(co.row + 1, co.hole + 1), Coordinate(co.row + 2, co.hole + 2)))
    end
    moves
end

struct Move
    fromh::Coordinate
    jumped::Coordinate
    to::Coordinate
end

struct GameState
    rows::Int
    empty_hole::Coordinate
    occupied_holes::Vector{Coordinate}

    function GameState(rows, empty_hole, occupied_holes)
        if length(occupied_holes) == 0
            for row in 1:rows, hole in 1:row
                (empty_hole.row == row && empty_hole.hole == hole) || push!(occupied_holes, Coordinate(row, hole))
            end
        end
        new(rows, empty_hole, occupied_holes)
    end
end

@inline function get_legal_moves(gs::GameState)::Vector{Move}
    legal_moves = Vector{Move}(undef, 0)
    for co in gs.occupied_holes
        moves = get_possible_moves(co, gs.rows)
        for move in moves
            contains_jumped = move.jumped in gs.occupied_holes
            contains_to = move.to in gs.occupied_holes
            contains_jumped && !contains_to && push!(legal_moves, move)  
        end
    end
    legal_moves
end

@inline function fast_filter(x::Vector{Coordinate}, y1::Coordinate, y2::Coordinate)
    oh_ix = BitVector(undef, length(x))
    for i in eachindex(oh_ix)
        oh_ix[i] = (x[i] != y1) & (x[i] != y2)
    end
    oh_ix
end

@inline function apply_move(gs::GameState, move::Move)::GameState
    move.to in gs.occupied_holes               && throw(error("Move is not consistent with game state: 'to' hole was occupied."))
    (move.to.row > gs.rows || move.to.row < 1) && throw(error("Move is not legal because the 'to' hole does not exist"))

    oh_ix = fast_filter(gs.occupied_holes, move.fromh, move.jumped)

    @inbounds new_gs = GameState(gs.rows, gs.empty_hole, push!(gs.occupied_holes[oh_ix], move.to))
    new_gs
end

struct GameCounter
    games_played::Int
    games_solution::Vector{Move}
end

increment(gc::GameCounter) = GameCounter(gc.games_played + 1, gc.games_solution)
increment(gc::GameCounter, move_stack::Vector{Move}) = GameCounter(gc.games_played + 1, append!(gc.games_solution, move_stack))


function search(gs::GameState, gc::GameCounter, move_stack::Vector{Move})
    if length(gs.occupied_holes) == 1
        return increment(gc, move_stack)
    end
    
    legal_moves = get_legal_moves(gs)
    
    if length(legal_moves) == 0
        return increment(gc)
    end
    
    for move in legal_moves
        new_gs = apply_move(gs, move)
        push!(move_stack, move)
        gc = search(new_gs, gc, move_stack)
        pop!(move_stack)
    end
    gc
end

function game()
    gs = GameState(5, Coordinate(3, 2), Vector{Coordinate}(undef, 0))
    gc = GameCounter(0, Vector{Move}(undef, 0))
    gc = search(gs, gc, Vector{Move}(undef, 0))
    gc
end

@time gc = game()
println("Games played: ", gc.games_played)
println("Games solution: ", length(gc.games_solution))
