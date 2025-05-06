import copy

from scripts.install.colors_definer import ColorsDefiner
from scripts.types.installation_color import InstallationMode, InstallationColor
from scripts.utils.color_converter.color_converter import ColorConverter


class ColorReplacementGenerator:
    def __init__(self, colors_provider: ColorsDefiner, color_converter: ColorConverter):
        self.colors = copy.deepcopy(colors_provider)
        self.color_converter = color_converter

    def convert(self, mode: InstallationMode, theme_color: InstallationColor) -> list[tuple[str, str]]:
        """Generate a list of color replacements for the given theme color and mode"""
        return [
            (element, self._create_rgba_value(element, mode, theme_color))
            for element in self.colors.replacers
        ]

    def _create_rgba_value(self, element: str, mode: str, theme_color: InstallationColor) -> str:
        """Create RGBA value for the specified element"""
        color_def = self._get_color_definition(element, mode)

        hue = color_def["h"] if "h" in color_def else theme_color.hue
        lightness = int(color_def["l"]) / 100
        saturation = int(color_def["s"]) / 100
        saturation = self._adjust_saturation(saturation, theme_color)
        alpha = color_def["a"]

        red, green, blue = self.color_converter.hsl_to_rgb(
            hue, saturation, lightness
        )

        return f"rgba({red}, {green}, {blue}, {alpha})"

    @staticmethod
    def _adjust_saturation(base_saturation: float, theme_color: InstallationColor) -> float:
        """Adjust saturation based on the theme color"""
        if theme_color.saturation is None:
            return base_saturation

        adjusted = base_saturation * (theme_color.saturation / 100)
        return min(adjusted, 1.0)

    def _get_color_definition(self, element: str, mode: str) -> dict:
        """Get color definition for element, handling defaults if needed"""
        replacer = self.colors.replacers[element]

        if mode not in replacer and replacer["default"]:
            default_element = replacer["default"]
            return self.colors.replacers[default_element][mode]

        return replacer[mode]
