import os
import click
import subprocess
import google.generativeai as genai
from dotenv import load_dotenv
from datetime import datetime # Import datetime for timestamping

# Load environment variables early
load_dotenv()

# --- 1. LLM API INTERACTION ---
def generate_scad_code(user_prompt: str, api_key: str) -> str:
    """Sends the prompt to the Google Gemini API and returns the generated SCAD code."""
    try:
        genai.configure(api_key=api_key)

        system_prompt = """
        You are an expert OpenSCAD programmer. Your task is to generate clean, correct, and parametric OpenSCAD code based on a user's request.
        **Instructions:**
        1.  **ONLY output the code.** Do not include any explanations, greetings, or markdown formatting like ```scad ... ```.
        2.  The code must be a single, complete, and valid .scad file.
        3.  Make the design parametric by using variables for key dimensions at the top of the script.
        4.  Add comments to explain the purpose of the variables.
        5.  The final line of the code must be the module instantiation that renders the object.
        6.  Do not use 'module' as an variable as it is a reserved word in openscad.
        """

        model = genai.GenerativeModel(
            model_name="gemini-2.5-flash",
            system_instruction=system_prompt,
            generation_config={"temperature": 0.2}
        )
 
        response = model.generate_content(user_prompt)
        cleaned_code = response.text.strip()

        # Clean up common model output issues
        if cleaned_code.startswith("```scad"):
            cleaned_code = cleaned_code[7:]
        if cleaned_code.endswith("```"):
            cleaned_code = cleaned_code[:-3]

        cleaned_code = cleaned_code.strip()

        # Basic sanity check
        if not cleaned_code or "module" not in cleaned_code:
            click.echo("⚠️ Warning: Output may not be valid OpenSCAD code.", err=True)

        return cleaned_code

    except Exception as e:
        click.echo(f"❌ Error: API call failed: {e}", err=True)
        return None

# --- 2. RENDERING BACKEND ---
def render_scad_file(scad_path: str, output_path: str):
    """Renders the SCAD file to a specified output format (STL or PNG) using OpenSCAD."""
    command = ["openscad", "-o", output_path, scad_path]
    if output_path.lower().endswith('.png'):
        # Added arguments for better PNG output quality and visibility
        # command.extend(["--camera=0,0,0,55,0,45,250", "--imgsize=800,600", "--view=axes,scales"])
        command.extend(["--imgsize=800,600", "--view=axes"]) 

    try:
        click.echo(f"⚙️  Rendering {os.path.basename(scad_path)} to {output_path}...")
        subprocess.run(command, check=True, capture_output=True, text=True)
        click.echo(f"✅ Rendering complete: {output_path}")
    except FileNotFoundError:
        click.echo("❌ Error: `openscad` not found. Is OpenSCAD installed and in your PATH?", err=True)
    except subprocess.CalledProcessError as e:
        click.echo("❌ Error during rendering.", err=True)
        click.echo(f"Command: {' '.join(e.cmd)}", err=True)
        click.echo(f"Exit Code: {e.returncode}", err=True)
        click.echo(f"stderr: {e.stderr}", err=True)

# --- 3. CLI ENTRY POINT (Updated) ---
@click.command()
@click.option('--prompt', '-p', required=True, help='A natural language description of the object.')
@click.option('--dir', '-d', 'output_dir', default='cadgen_output', 
              help='The name of the output directory to save all files.') # Directory name
@click.option('--base-name', '-b', default='model', 
              help='The base name for the files inside the directory (e.g., "my_part_v2").') # File base name
@click.option('--api-key', envvar='GOOGLE_API_KEY', help='Your Google AI Studio API key. Can also be set via GOOGLE_API_KEY env var.')
@click.option('--render-stl','-r', is_flag=True, help='Also render an STL file.')
@click.option('--render-png','-i', is_flag=True, help='Also render a PNG preview.')
def main(prompt, output_dir, base_name, api_key, render_stl, render_png):
    """A CLI tool to generate 3D models from a text prompt using Google Gemini and OpenSCAD."""

    if not api_key:
        click.echo("❌ Error: Google API key not found. Set it in .env or pass via --api-key.", err=True)
        return

    # --- Directory Modification Logic: Append timestamp if using default directory ---
    default_dir = 'cadgen_output'
    if output_dir == default_dir:
        # Format the timestamp as YYYYMMDD_HHMMSS
        timestamp = datetime.now().strftime("_%Y%m%d_%H%M%S")
        output_dir = default_dir + timestamp
    # --------------------------------------------------------------------------------

    # --- 1. Directory Setup ---
    try:
        os.makedirs(output_dir, exist_ok=True)
        
        click.echo(f"📁 Ensuring output directory exists: {output_dir}")
    except OSError as e:
        click.echo(f"❌ Error creating directory {output_dir}: {e}", err=True)
        return

    # --- 2. Generation ---
    click.echo("🤖 Contacting Google Gemini to generate OpenSCAD code...")
    scad_code = generate_scad_code(prompt, api_key)

    if not scad_code:
        click.echo("💥 Failed to generate SCAD code. Aborting.", err=True)
        return

    # --- 3. Save SCAD File ---
    scad_filename = os.path.join(output_dir, f"{base_name}.scad")
    try:
        with open(scad_filename, "w") as f:
            f.write(scad_code)
        click.echo(f"✅ SCAD code saved to {scad_filename}")
    except Exception as e:
        click.echo(f"❌ Failed to save SCAD file: {e}", err=True)
        return

    # --- 4. Render Files ---
    if render_stl:
        stl_filename = os.path.join(output_dir, f"{base_name}.stl")
        render_scad_file(scad_filename, stl_filename)

    if render_png:
        png_filename = os.path.join(output_dir, f"{base_name}.png")
        render_scad_file(scad_filename, png_filename)

    click.echo("🎉 All tasks completed successfully.")

if __name__ == '__main__':
    main()