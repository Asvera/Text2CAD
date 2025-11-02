import subprocess
import google.generativeai as genai
import os

# Custom Error for our application
class ScadGenerationError(Exception):
    pass

class ScadRenderError(Exception):
    pass

def generate_scad_code(user_prompt: str, api_key: str) -> str:
    """Sends the prompt to the Google Gemini API and returns the code."""
    try:
        genai.configure(api_key=api_key)
        system_prompt = """
        You are an expert OpenSCAD programmer...
        (Your full system prompt here)
        """
        
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash-latest",
            system_instruction=system_prompt,
            generation_config={"temperature": 0.2}
        )
        
        response = model.generate_content(user_prompt)
        cleaned_code = response.text.strip().removeprefix("```scad").removesuffix("```").strip()
        
        if not cleaned_code:
            raise ScadGenerationError("LLM returned an empty response.")
            
        return cleaned_code

    except Exception as e:
        # Raise our custom error so the CLI can catch it
        raise ScadGenerationError(f"API call failed: {e}")

def render_scad_file(scad_path: str, output_path: str):
    """Renders a .scad file to an STL or PNG using the OpenSCAD CLI."""
    command = ["openscad", "-o", output_path, scad_path]
    if output_path.lower().endswith('.png'):
        command.extend(["--camera=0,0,0,55,0,45,250", "--imgsize=800,600", "--view=axes,scales"])

    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        return f"Rendering complete: {output_path}" # Return success message
    except FileNotFoundError:
        raise ScadRenderError("`openscad` command not found. Is OpenSCAD installed and in your PATH?")
    except subprocess.CalledProcessError as e:
        raise ScadRenderError(f"OpenSCAD rendering failed:\n{e.stderr}")