import click
import os
from dotenv import load_dotenv
from . import core  # <-- This relative import is fine, no change needed

@click.group()
def main():
    """A CLI tool to generate and render OpenSCAD models."""
    load_dotenv()

# ... (rest of your render and generate commands are unchanged) ...

@main.command()
@click.argument('input_file', type=click.Path(exists=True, dir_okay=False))
@click.option('--output', '-o', help='Output file path (STL/PNG).')
def render(input_file, output):
    """Renders an existing .scad file to STL or PNG."""
    if not output:
        base_name = os.path.splitext(input_file)[0]
        output = f"{base_name}.stl"
        click.echo(f"No output file specified. Defaulting to {output}")

    try:
        success_message = core.render_scad_file(input_file, output)
        click.echo(f"✅ {success_message}", fg="green")
    except core.ScadRenderError as e:
        click.echo(f"💥 Render Error: {e}", err=True, fg="red")

@main.command()
@click.option('--prompt', '-p', required=True, help='A natural language description.')
@click.option('--output', '-o', default='model', help='The base name for the output files.')
@click.option('--api-key', envvar='GOOGLE_API_KEY', help='Your Google API key.')
@click.option('--render-stl', is_flag=True, help='Also render an STL file.')
@click.option('--render-png', is_flag=True, help='Also render a PNG preview.')
def generate(prompt, output, api_key, render_stl, render_png):
    """Generates a .scad file from a text prompt."""
    if not api_key:
        api_key = os.getenv('GOOGLE_API_KEY')
    if not api_key:
        click.echo("💥 Error: Google API key not found.", err=True, fg="red")
        return

    try:
        # --- Generate Code ---
        click.echo("🤖 Contacting Google Gemini...")
        scad_code = core.generate_scad_code(prompt, api_key)
        
        scad_filename = f"{output}.scad"
        with open(scad_filename, "w") as f:
            f.write(scad_code)
        click.echo(f"✅ SCAD code saved to {scad_filename}", fg="green")

        # --- Render Files ---
        if render_stl:
            click.echo("⚙️  Rendering STL...")
            success_msg = core.render_scad_file(scad_filename, f"{output}.stl")
            click.echo(f"✅ {success_msg}", fg="green")
        
        if render_png:
            click.echo("⚙️  Rendering PNG...")
            success_msg = core.render_scad_file(scad_filename, f"{output}.png")
            click.echo(f"✅ {success_msg}", fg="green")

    except (core.ScadGenerationError, core.ScadRenderError) as e:
        click.echo(f"💥 Error: {e}", err=True, fg="red")