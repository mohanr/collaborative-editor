
module MakeConfigurer = struct

type  config = {

  width : int;
  height : int;

}
end

module type Configurer=
sig

  include module type of MakeConfigurer
  val set_size : int -> int ->  config

end



module type MAKER = Configurer
module type Intf = sig
  module Make : MAKER

end
