--
-- Basic A* search.

local AStarSearcher = class("AStarSearcher")

-- distfn( current_node, neighbour )
--  Distance metric, returns distance between nodes.
-- heuristicfn( neighbour, end_node )
--  Heuristic function for the distance between node and the goal node
-- neighbours( node )
--  returns a table of neighbours of node

-- Call StartSearch( node, goal_node ) to declare the search.
--   (1) Step() until FoundPath() returns true
--  OR
--   (2) RunToCompletion()
--
-- If there is a path, GetPath() will return a table of nodes from (start_node, .. , end_node)

function AStarSearcher:init(distfn, heuristicfn, neighbours)
    self.closed_set = {}
    self.open_set = {}
    self.came_from = {}
    self.g_score = {}
    self.f_score = {}
    self.path = {}
    self.status = "init"
    self.heuristicfn = heuristicfn
    self.distfn = distfn
    self.neighbours = neighbours
end

function AStarSearcher:Reset()

    table.clear(self.closed_set)
    table.clear(self.open_set)
    table.clear(self.came_from)
    table.clear(self.f_score)
    table.clear(self.g_score)
    table.clear(self.path)
    self.start_node = nil
    self.end_node = nil
end


function AStarSearcher:process_neighbour(current_node, neighbour)
    if not self.closed_set[neighbour] then

        local g = self.g_score[current_node] + self.distfn(current_node, neighbour)
        if not self.open_set[neighbour] or g < self.g_score[neighbour] then
            self.came_from[neighbour] = current_node
            self.g_score[neighbour] = g
            self.f_score[neighbour] = g + self.heuristicfn(neighbour, self.end_node)
            self.open_set[neighbour] = true
        end
    end
end

function AStarSearcher:Step()
    if self.status == "searching" then
        if next(self.open_set) then

            local current_node = nil
            local lowest_score = nil
            for k,v in pairs(self.open_set) do
                local score = self.f_score[k]
                if not lowest_score or lowest_score > score then
                    current_node = k
                    lowest_score = score
                end
            end

            if current_node == self.end_node then
                self:_ConstructPath()
                if not self.no_clear then
                    table.clear(self.closed_set)
                    table.clear(self.open_set)
                    table.clear(self.came_from)
                    table.clear(self.f_score)
                    table.clear(self.g_score)
                end
                self.status = "done"
                self.score = lowest_score
                return
            end

            self.open_set[current_node] = nil
            self.closed_set[current_node] = true
            
            for _, neighbour in self.neighbours(current_node) do
                self:process_neighbour(current_node, neighbour)
            end

        else
            if not self.no_clear then
                table.clear(self.closed_set)
                table.clear(self.open_set)
                table.clear(self.came_from)
                table.clear(self.f_score)
                table.clear(self.g_score)
            end
            self.status = "nopath"
        end
    end
end

function AStarSearcher:GetPath()
    return self.path
end

function AStarSearcher:_ConstructPath()
    table.clear(self.path)
    
    local node = self.end_node
    while node do
        table.insert(self.path, node)
        node = self.came_from[node]
    end
    table.reverse(self.path)
    
end

function AStarSearcher:FoundPath()
    return self.status == "done"
end

function AStarSearcher:GetScore()
    return self.score
end

function AStarSearcher:RunToCompletion()
    while self.status == "searching" do 
        self:Step()
    end
end

function AStarSearcher:StartSearch(start_node, end_node)
    self:Reset()
    
    self.start_node = start_node
    self.end_node = end_node

    self.open_set[self.start_node] = true
    self.g_score[self.start_node] = 0
    self.f_score[self.start_node] = self.heuristicfn(self.start_node, self.end_node)
    self.status = "searching"
    
end
