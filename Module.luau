return(function(...)
local a,b,c={...},{},{}
local d=(getgenv or getrenv or b[4])()

local e=d.connections or{}do
d.connections=e

for f=1,#e do
e[f]:Disconnect()
end

table.clear(e)
end

local function packages(f,g)
local h=g()

a[f]=h

return a[f]
end

local f=cloneref or(function(...)return(...)end)

packages("reference",function()
return(function(g)
return f(game:GetService(g))
end)
end)

local g=a.reference'RunService'
a.reference'Lighting'
a.reference'TeleportService'
local h=a.reference'HttpService'
a.reference'Players'
a.reference'UserInputService'
local i=a.reference'VirtualUser'

local j=game.PlaceId

packages("database",function()
local k={
folder="XZER"
}

local l=isfolder or(function(...)return(...)end)
local m=makefolder or(function(...)return(...)end)
local n=isfile or(function(...)return(...)end)
local o=readfile or(function(...)return(...)end)
local p=writefile or(function(...)return(...)end)

local function build()
local q={
k.folder,k.folder.."/settings"
}

for r=1,#q do
local s=q[r]

if not l(s)then
m(s)
end
end
end

local q=k.folder.."/settings/"..j..".json"

function k.def(r,s,t)
if c[s]==nil then
c[s]=t
end
end

function k.save(r,s,t)
if s~=nil then
Configs[s]=t
end

if not l(k.folder)then
m(k.folder)
end

if not l(k.folder.."/settings")then
m(k.folder.."/settings")
end

p(q,h:JSONEncode(c))
end

function k.load(r)
if not n(q)then
k:save()
end

return h:JSONDecode(o(q))
end

build()
k:def('Initailized',true)

return k
end)

packages("waitforchild",function()
return(function(k)
local l,m=5

for n in k do
m=m:WaitForChild(n,l)

if not m then
warn("Timeout : "..n)
return nil
end
end

return m
end)
end)

packages("newconnection",function()
return(function(k,l)
return table.insert(e,k:Connect(l))
end)
end)

packages("afk",function()
return(function(k)
a:newconnection(k.Idled,function()
i:CaptureController()
i:ClickButton2(Vector2.new())
end)
end)
end)

packages("fontcolors",function()
return(function(k,l)
if type(k)=="string"and typeof(l)=="Color3"then
local m,n,o=math.floor(l.R*255),math.floor(l.G*255),math.floor(l.B*255)

return string.format('<font color="rgb(%d, %d, %d)">%s</font>',m,n,o,k)
end

return k
end)
end)

packages("whiles",function()
return(function(k,l,m,n)
while k do
local o=tick()

if m then m()end
if n and n()then break end

repeat
g.Heartbeat:Wait()
until tick()-o>=(l or 0.1)
end
end)
end)

packages('theard',function()
return(function(k,l,m)
nets[k]=function(n)
a:whiles(n,l or 0.1,m,function()
return not n
end)
end
end)
end)

packages('import',function()
local k={
owner="setmetata6le",
once=true,
}

function k.fetch(l,m,n)
local o=string.format(
'https://raw.githubusercontent.com/%s/%s/refs/heads/main/Packages/%s.luau',
l.owner,
m,
n
)

local p=game:HttpGet(o)
return loadstring(p,l.once)()
end

return k
end)

packages('components',function()
local k={}
local l=a.import:fetch("Script",'init')
print(typeof(l))

return k
end)

c=a.database:load()

return a
end)(setmetatable,newproxy,getfenv)
