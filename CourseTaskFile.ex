defmodule Coordinate do
defstruct [:lat , :lon]
end






defmodule Location do

defstruct [:coordinate , :name , :type , :landmark , :cafe , restaurant , :shop]

def new(coordinate , name , type) do

{:ok , location1} = Location.new(%Coordinate{lat: coordinate , lon: coordinate}, name: name , type: type)
{:ok , location2} = Location.new(%Coordinate{lat: coordinate , lon: coordinate}, name: name , type: type)

end	


def distance ({x1,y1} , {x2,y2} ) do
location1 = x1-y1
location2 = x2-y2

:math.sqrt(location1 * location1 + location2 * location2)
end


end




defmodule Route do

defstruct [:lacation , :landmark , :cafe , :restaurant , :shop , :name ]


def length_route(route) do
route
|> Enum.map(fn x -> to_string(x) end)
|> Enum.map(fn x -> String.length(x) end)
end



def print(route) do
route
|> Enum.map(fn x -> to_string(x) end)
|> Enum.reduce(fn x , acc -> acc <> "->" <> x end )
end

end







defmodule Routes do

use GenServer

# Interface

def start_link(_) do
GenServer.start_link(__MODULE__ , [] ,name: __MODULE__)
end

def add(new_route) do
GenServer.cast(__MODULE__ , {:add , new_route})
end

def destroyed(name) do
GenServer.cast(__MODULE__ , {:destroyed , name})
end


def print_all() do
GenServer.call(__MODULE__ , :print_all)
end


#Internal



def init(_) do
{:ok , RoutesBackup.get_last_backup()}
end

def handle_cast({:add , %Route() = new_route},list_of_routes) do
new_state = [new_route | list_of_routes]
RoutesBackup.backup(new_state)
{:noreply , new_state}
end



def handle_cast({:destroyed , name},list_of_routes) do
new_state = Enum.filter(list_of_routes , fn route  -> name != route.name end )
RoutesBackup.backup(new_state)
{:noreply , new_state}
end




def handle_call(:print_all , _from , list_of_routes) do
{:reply , list_of_routes , list_of_routes}
end

end




defmodule RoutesBackup do

use GenServer

def start() do
 Agent.start(fn -> [] end , name: __MODULE__)
end


def get_last_backup() do
 Agent.get(__MODULE__ , fn state -> state end )
end


def backup(state) do
 Agent.update(fn _ -> state end)
end

end




defmodule RoutesSupervised.Application do

use Application

def start(_type, _args) do

children = [


{RoutesBackup,[]}
{Routes,[]}

]

opts= [ strategy: :one_for_one , name: RoutesSupervised.Supervisor ]
Supervisor.start_link(children  , opts )
end
end
