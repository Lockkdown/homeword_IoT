import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LightControlScreen extends StatefulWidget {
  const LightControlScreen({super.key});

  @override
  State<LightControlScreen> createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen> {
  bool _isOn = false;
  double _intensity = 0.33;

  static const String _bulbPath = 'M17.0529 30.9982C17.5045 30.9982 17.8498 30.6529 17.8498 30.2014L17.8498 28.4219C19.2842 28.0766 20.3203 26.7749 20.3203 25.2608L20.3203 23.1358C20.3203 21.9671 20.7984 20.8515 21.6484 20.0811C23.2953 18.6202 24.1185 16.5219 23.9592 14.3438C23.6935 10.8906 20.9046 8.1549 17.4249 7.91583C17.2655 7.91583 17.1329 7.88886 16.9735 7.88886C15.1142 7.88886 13.3611 8.60636 12.033 9.93448C10.7315 11.2892 10.0139 13.0421 10.0139 14.9015C10.0139 16.8671 10.8641 18.7796 12.3516 20.0811C13.2547 20.9046 13.786 22.047 13.786 23.2157L13.786 25.2608C13.786 26.8015 14.8482 28.0766 16.256 28.4219L16.256 30.2014C16.256 30.6529 16.6014 30.9982 17.0529 30.9982ZM17.0799 26.9345C16.6815 26.4829 16.4158 25.8983 16.4158 25.2608L16.4158 23.5877L18.7266 23.5877L18.7266 25.2608C18.7266 26.164 17.983 26.9079 17.0799 26.9345ZM18.8329 22.0204L15.2205 22.0204C14.9549 20.8517 14.3173 19.7623 13.3876 18.9123C12.2454 17.9029 11.5811 16.4421 11.5811 14.9015C11.5811 13.4671 12.139 12.1127 13.1749 11.1033C14.2905 10.0143 15.7783 9.42979 17.3455 9.53604C20.0018 9.69542 22.1795 11.8203 22.3654 14.4766C22.4982 16.1766 21.8344 17.7701 20.5859 18.9123C19.6828 19.7092 19.072 20.8251 18.8329 22.0204ZM28.1562 15.6983C28.6078 15.6983 28.9531 15.353 28.9531 14.9015C28.9531 14.4499 28.6078 14.1046 28.1562 14.1046L26.908 14.1046C26.4565 14.1046 26.1111 14.4499 26.1111 14.9015C26.1111 15.353 26.4565 15.6983 26.908 15.6983L28.1562 15.6983ZM7.09198 15.6983C7.54354 15.6983 7.88886 15.353 7.88886 14.9015C7.88886 14.4499 7.51698 14.1046 7.09198 14.1046L5.84375 14.1046C5.39219 14.1046 5.04688 14.4499 5.04688 14.9015C5.04688 15.353 5.39219 15.6983 5.84375 15.6983L7.09198 15.6983ZM24.0027 8.71271C24.2053 8.71271 24.4109 8.63292 24.5703 8.47354L25.4471 7.59677C25.7658 7.27802 25.7658 6.77354 25.4471 6.48135C25.2877 6.32198 25.0748 6.24219 24.8889 6.24219C24.6764 6.24219 24.4905 6.32198 24.3311 6.48135L23.4549 7.35761C23.1361 7.67636 23.1361 8.18136 23.4549 8.47354C23.601 8.63292 23.8002 8.71271 24.0027 8.71271ZM9.99725 8.71271C10.1998 8.71271 10.399 8.63292 10.5451 8.47354C10.8639 8.15479 10.8639 7.64979 10.5451 7.35761L9.66885 6.48136C9.50948 6.32198 9.29708 6.24219 9.11114 6.24219C8.89865 6.24219 8.71229 6.32198 8.55292 6.48136C8.23417 6.80011 8.23417 7.30459 8.55292 7.59677L9.42969 8.47354C9.58906 8.63292 9.79471 8.71271 9.99725 8.71271ZM17 5.81729C17.4516 5.81729 17.7969 5.47198 17.7969 5.02042L17.7969 3.79865C17.7969 3.34708 17.4516 3.00177 17 3.00177C16.5484 3.00177 16.2031 3.34708 16.2031 3.79865L16.2031 5.02042C16.2031 5.47198 16.5484 5.81729 17 5.81729Z';

  void _toggleLight() {
    setState(() {
      _isOn = !_isOn;
      if (_isOn) _intensity = 0.33;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF324539),
      body: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 360,
          height: 800,
          child: Stack(
            children: [
              _buildGlowEllipse(),
              _buildLampImage(),
              _buildLightBeam(),
              _buildHeader(),
              _buildLightNameText(),
              _buildToggle(),
              _buildSliderSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEllipse() {
    // Exact logical size and positions from Figma
    // OFF and ON low: 280x280 at (67, 164)
    // ON high: 282x282 at (58, 163)
    final double size = _isOn ? 280.0 + (282.0 - 280.0) * _intensity : 280.0;
    final double left = _isOn ? 67.0 - (67.0 - 58.0) * _intensity : 67.0;
    final double top = _isOn ? 164.0 - (164.0 - 163.0) * _intensity : 164.0;

    // Blur radius and colors based on the actual Figma SVGs:
    // OFF: black, opacity 0.25, blur 52
    // ON Low: #F8F5DD, opacity 0.3, blur 52
    // ON High: #F8F5DD, opacity 0.8, blur 90
    final Color color;
    final double blurRadius;

    if (!_isOn) {
      color = Colors.black.withValues(alpha: 0.25);
      blurRadius = 52.0;
    } else {
      // Interpolate between ON low (intensity=0) and ON high (intensity=1)
      final double opacity = 0.3 + (0.8 - 0.3) * _intensity;
      color = const Color(0xFFF8F5DD).withValues(alpha: opacity);
      blurRadius = 52.0 + (90.0 - 52.0) * _intensity;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: left,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Figma's "fill with blur" translates directly to a colored circle
          // with a shadow of the same color, but since we just want the glow,
          // we can use a transparent fill and a shadow, or just color the circle
          // and let the shadow bleed out. Actually, Figma's circle has the fill
          // AND the blur applied to that fill. In Flutter, we can achieve this
          // with a BoxShadow having no offset.
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: blurRadius,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLampImage() {
    return Positioned(
      left: 124,
      top: 0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Image.asset(
          _isOn ? 'assets/images/lamp_on.png' : 'assets/images/lamp_off.png',
          key: ValueKey(_isOn),
          width: 199,
          height: 327,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const SizedBox(width: 199, height: 327),
        ),
      ),
    );
  }

  Widget _buildLightBeam() {
    return Positioned(
      // The light beam SVG contains a blur filter causing the viewBox to be larger (78x29).
      // The actual path starts roughly at x=3.5, y=3.5.
      // We want the visual path to sit at left: 188, top: 290.
      // So the container needs to be offset by -3.5 on both axes.
      left: 184.5,
      top: 286.5,
      child: SvgPicture.asset(
        'assets/images/light_beam.svg',
        width: 78,
        height: 29,
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      left: 28,
      right: 0,
      top: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Kitchen',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightNameText() {
    return Positioned(
      left: 35,
      right: 35,
      top: 503,
      child: Text(
        'Island Kitchen Bar\nLED Pendant Ceiling Light',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Positioned(
      left: 36,
      right: 0,
      top: 575,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _toggleLight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 70,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                color: _isOn
                    ? const Color(0xFFA9BDB2)
                    : const Color.fromRGBO(193, 193, 193, 0.5),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: _isOn ? 44.0 : 5.0,
                    top: 4.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOn
                            ? const Color(0xFF324539)
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            _isOn ? 'ON' : 'OFF',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection() {
    return Positioned(
      left: 0,
      right: 0,
      top: 645,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isOn ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !_isOn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 6),
                child: Text(
                  'Light Intensity',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 28),
                  _buildBulbIcon(dim: true),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.4),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayColor: Colors.white.withValues(alpha: 0.2),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: _intensity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() => _intensity = value);
                        },
                      ),
                    ),
                  ),
                  _buildBulbIcon(dim: false),
                  const SizedBox(width: 28),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulbIcon({required bool dim}) {
    final String svg = '''<svg width="34" height="34" viewBox="0 0 34 34" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="$_bulbPath" fill="white"${dim ? ' fill-opacity="0.3"' : ''}/></svg>''';

    return SizedBox(
      width: 34,
      height: 34,
      child: SvgPicture.string(
        svg,
        width: 34,
        height: 34,
      ),
    );
  }
}
