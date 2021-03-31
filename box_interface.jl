#Box Test

#Color
white() = create_layer("White", true, rgb(255/255, 255/255, 255/255))
red() = create_layer("Red", true, rgb(255/255, 0/255, 0/255))
blue() = create_layer("Blue", true, rgb(0/255, 0/255, 255/255))
green() = create_layer("Green", true, rgb(0/255, 255/255, 0/255))

#Material
box_material(length, width, height, material) =
  begin
    set_backend_family(default_slab_family(), meshcat, meshcat_material_family(material))
    with_slab_family(thickness=height) do
    slab(rectangular_path(u0(), length, width)) end
  end

#box_material(3, 4, 5, meshcat_metal_material())
#box_material(3, 4, 5, meshcat_material(RGB(0.5,0.5,0.5)))

#autocad/rhino material?
#robot/frame 3dd material?

delete_all_shapes()


#Parameters
#length = 20
#width = 40
#height = 30
#color = white()

#Geometry
using Khepri

box_color(length, width, height, color) =
  with(current_layer, color) do
    box(u0(), length, width, height)
  end

#backend(autocad)
#box_color(20, 40. 30, white())

box_volume(length, width, height) =
  length*width*height

#UI
using Interact

dropdown2(options, ;label) =
  let
    l = pad(1em, label)
    d = dropdown(options)
    wdg = Widget(d)
    @layout! wdg hbox(l, d)
  end

length_ui() = widget(1:1:100, value=20, label="Length")
width_ui() = widget(1:1:100, value=40, label="Width")
height_ui() = widget(1:1:100, value=30, label="Height")
color_ui() = dropdown2(OrderedDict("White"=>white(), "Red"=>red(), "Blue"=>blue(), "Green"=>green()), label="Color")

sliders() = @manipulate for l=length_ui(),
                            w=width_ui(),
                            h=height_ui(),
                            c=color_ui()
                            delete_all_shapes()
                            box_color(l, w, h, c)
                            nothing
                            "Volume: $(box_volume(l, w, h))"
                        end

#Desktop UI + Visualizer
backend(meshcat)
render_size(300, 300)
ui() = hbox(sliders(), display_view(meshcat))


using Blink
w() = title(Blink.Window(), "Box")
body!(w(), ui())

#Web UI + Visualizer
using WebIO, Mux
webio_serve(page("/", req -> ui()), 8000) #In: http://localhost:8000/
#BUG: server conflicts with meshcat one

#Desktop UI + AutoCAD
backend(autocad)
body!(w(), sliders())

#Web UI + AutoCAD
webio_serve(page("/", req -> sliders()), 8004) #In: http://localhost:8004/
#BUG: remote
