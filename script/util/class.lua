CLASSES = {}

local sized_table = rawget(_G, "create_sized_table")

local function readonly_err( t, k, v )
    error( "can't assign to instance" )
end

class = function( name, ... )
    -- Break down class name into "."-delimited sub-parts. 
    local fullname = name
    local name_parts = {}
    for w in string.gmatch( name, "([^.]+)" ) do
        assert( not w:match("%s"), w) -- No whitespace!
        table.insert(name_parts, w)
    end
	
    local t = _G
    for i = 1, #name_parts - 1 do
        name = name_parts[i]
        local nextt = rawget( t, name )
        if nextt == nil then
            nextt = {}
            rawset( t, name, nextt )
        end
        t = nextt
    end
    
    name = name_parts[#name_parts]
    local cl = rawget( t, name )
    if cl ~= nil then
        assert( cl.can_reload, "Tried to define a class that already exists: ".. name)
        print( "Reloading Class:", fullname )
        table.clear( cl )
    else
        cl = {}
        rawset( t, name, cl )
    end

    cl._class = cl
    cl._classname = fullname
    local baseclasses = select( "#", ... )
    if baseclasses > 1 then
        cl._bases = { ... }
    --     cl.__index = function( t, k )
    --         local v = rawget( cl, k )
    --         if v ~= nil then
    --             return v
    --         end
    --         for i, baseclass in ipairs( cl._bases ) do
    --             local v = baseclass[ k ]
    --             if v ~= nil then
    --                 return v
    --             end
    --         end
    --     end
        cl.__index = cl
    else
        cl._base = select( 1, ... )
        cl.__index = cl
    end

    cl._subclasses = table.empty

    for i = 1, baseclasses do
        local baseclass = select( i, ... )
        if baseclass._subclasses == table.empty then
            baseclass._subclasses = {}
        end
        table.insert( baseclass._subclasses, cl )
    end

    local deffile = debug.getinfo(2, "S").source
    cl._file = string.gsub(deffile, "^@", "")

    cl.__serialize = function( self )
        self._classname = fullname
        return self
    end

    cl.strictify = function( self )
        self.__newindex = readonly_err
        return self
    end

    cl.init_bases = function( self, ... )
        local base = rawget( cl, "_base" )
        if base then
            if base.init then
                base.init( self, ... )
            end
            return
        end

        local bases = rawget( cl, "_bases" )
        if bases then
            for i, base in ipairs( bases ) do
                if base.init then
                    base.init( self, ... )
                end
            end
        end
    end

    cl.new = function(self, ...)
        local inst= nil
        
        if sized_table then
            inst = sized_table(0, cl._start_table_size or 16)
        else
            inst = {}
        end

        setmetatable(inst, cl)
       
        if cl.init then
            cl.init(inst, ...)
        end

        if cl._strict then
            --metamethods are looked up with rawget, so we have to copy tostring forward manually
            cl._strict.__tostring = cl.__tostring
            setmetatable(inst, cl._strict)
        end

        return inst    
    end

    if baseclasses == 1 then
        local baseclass = select( 1, ... )
        --metamethods are looked up with rawget, so we have to copy tostring forward manually
        cl.__tostring = baseclass.__tostring

        if baseclass.__newindex then
            cl._strict = { __tostring = cl.__tostring, __index = cl, __newindex = baseclass.__newindex }
        end

        setmetatable( cl, { __index = baseclass, __call = cl.new})

    elseif baseclasses > 1 then
        local function __index( t, k )
            for i, base in ipairs( t._bases ) do
                local v = base[k]
                if v ~= nil then
                    return v
                end
            end
        end

        for i, baseclass in ipairs( cl._bases ) do
            if baseclass.__tostring ~= nil then
                cl.__tostring = baseclass.__tostring
                break
            end
        end

        setmetatable( cl, { __index = __index, __call = cl.new })

    else
        setmetatable( cl, { __call = cl.new})
    end


    CLASSES[ fullname ] = cl
    return cl
end

function base_match(c1, c2)
    if c1 == c2 then return true end

    if c1._base then
        return base_match(c1._base, c2)
    elseif c1._bases then
        for i, base in ipairs( cl._bases) do
            if base_match(base, c2) then
                return true
            end
        end
    end

    return false
end

function get_subclasses( class )
    return class._subclasses
end

is_class = function(class, base_class)
    if type(class) == "table" and rawget( class, "_class" ) == class then
        if base_class == nil then
            return true -- Is a class: good enough!
        else
            return base_match(class, base_class)
        end

    else
        return false
    end
end

recurse_subclasses = function( class, fn )
    class = class or Verb
    fn( class )

    for i, subclass in ipairs( class._subclasses ) do
        recurse_subclasses( subclass, fn )
    end
end


is_instance = function(inst, class)
    assert( is_class( class ))
    if type(inst) == "table" then
        if inst._class and inst._class ~= inst then
            if (class == nil or inst._class == class) then
                return true
            end
            if inst._base and base_match(inst._base, class) then
                return true
            elseif inst._bases then
                for i, base in ipairs( inst._bases ) do
                    if base_match(base, class) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function reload_class(class)
    local filename = class._file:match( "^[.][.]/scripts/(.+)[.]lua$" )
    package.loaded[ filename ] = nil
    local ok, err = pcall( require, filename )
    assert_warning(ok, err)
end
