
*FreeBOMS is a Free Bill of Materials Build System*


# Databases

FreeBOMBS uses a database consisting of the following YAML files in a folder.
There is an example database included in the dbs directory; ``freeems-puma-spin1``
- Mandatory keys are in **bold**
- Markdown is allowed (but not supported yet) in at least ``title`` and ``description`` fields.


## component_types.yaml

This is a definition list of component types (not implemented yet)


## ``suppliers.yaml``

A list of known/supported component suppliers. Each key on the top level is the supplier ID.
Any unique string is allowed. Each value MUST be a Hash containing the following items:
- **title**: Human (user) -readable string; the full name of the supplier.
- **homepage**: The home-page URL of the supplier.


## ``components.yaml``

A database of all components used in the project.
Each key on the top level is the manufacturer ID code of the component. These MUST be unique.
If the ID is shared amongst several vendors or is otherwise generic, suffix the ID with a unique identifier.
The part number in the supplier section of the component defines which exact component to use.
There MUST be a Hash for each key. What's defined below is the contents of each key.


### Structure of an obsolete component

- **title**: A single-line description of the component
- **obsolete**: MUST be true
- replacement: A reference ID to an equivalent part, which MUST be defined in the components database

Any items of a normal component are allowed, but not mandatory.


### Structure of a normal component
- **title**: A single-line description of the component
- **description**: A multi-line description of the component. Optional, if a datasheet URL is defined.
- **datasheet**: An URL to the datasheet of the component. Optional, if the description is defined.
- **suppliers**: A Hash containing supplier ID's as keys and the following items as the value (Hash):
  - **part**: The part number of the supplier as a String.
  - **price**: A pair of values in an Array:
    1. The price as a number, eg. ``0.053`` or ``18.84`` or ``37``
    2. The currency of the price, only ``USD`` and ``EUR`` supported currently.

Currently, any extra key-value pairs are allowed, but not supported. Support will be added,
when component_types.yaml is defined.


## ``configurations.yaml``

A structure defining, which components are used in which configuration.


### Component references:
Component references are defined as an Array containing the amount and component ID of the component used.
1. Amount of the component (number)
2. Component ID of the component (string)

Example: ``[ 4, 'RMCF0805JT1K60' ]``


#### Alternative syntax:
When only one compnent is needed, the Array pair containing the amount may be omitted, just supply the component ID as a string instead.

Example: ``'RMCF0805JT1K60'``


### Top-level structure (the project itself)
- **title**: A single-line string defining the name of the project.
- **description**: A multi-line string defining the purpose and general info about the project.
- **components**: A list of baseline components as an Array, see "Component references". These are always included in the BOM.
- **sections**: A list of section definitions (see below; "Section structure".
- **section_order**: A list of section ID's defining in which order to present the sections to the user.


### Section structure
- **title**: A single-line string defining the name of the project.
- **description**: A multi-line string defining the purpose and general info about the project.
- **value**: The default amount of component sets of in this section to include in the BOM.
- **min**: The minimum value.
- **max**: The maximum value.
- checked: Whether to enable the section by default or not. Allowed values: true or false
- presets: A list of pre-set values with titles. An array containing Hash structures defined as:
  - **title**: The title of the preset, should be descriptive.
  - **value**: The value preset to apply, if selected. Can't be greater than max or less than min.
- excludes: A section ID defining a single other section to uncheck, if checked. Can also be defined as a list of section ID's to uncheck, when checked.
- components: A list of baseline components as an Array, see "Component references".
  - The amounts are multiplied by the value entered.
  - Obsolete component references with a replacement defined show a warning.
  - Obsolete compnonet references without a replacement are treated as errors.


# Validating the database:


You'll need the following dependencies installed:

 - Ruby
 - RubyGems (if Ruby version is below 1.9)
 - ``gem install yaml`` (if Ruby version is below 1.9)
 

Run the valitation script like this:

``ruby test/check_db_sanity.rb``

