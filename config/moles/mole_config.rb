HousesController.mole_after( :feature => :index ) do |context, feature, ret, block, *args|
  ::Mole::Moler.mole_it( 
    context               , 
    feature,
    context.session[:map_area_id],
    :min_price =>context.instance_variable_get( "@min_price" ) ,
    :max_price =>context.instance_variable_get( "@max_price" ),
    :num_houses =>context.instance_variable_get( "@house_count" ))
end


HousesController.mole_after(:feature => :save_it) do |context, feature, ret, block, *args|
  ::Mole::Moler.mole_it( 
    context               , 
    feature               ,
    context.session[:user_id],
    :house=>context.instance_variable_get( "@house" ))
end