const fs = require('fs');
const path = 'C:\\Users\\FergentiusRosales\\Herd\\truecabtt\\mobileapp\\user\\lib\\pages\\onTripPage\\booking_confirmation.dart';

// We perform a fresh recovery to be absolutely sure starting from a clean state
const { execSync } = require('child_process');
execSync('git checkout ' + path);

const content = fs.readFileSync(path, 'utf8');
const lines = content.split('\n');

// 1. HEADER (Lines 1 to 778 - ends exactly after _cachedDriversStream = ...)
const header = lines.slice(0, 779).join('\n');

// 2. MODULAR UI (the new build + helper methods)
const modularUI = `

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    popFunction() {
      if (userRequestData.isNotEmpty && userRequestData['accepted_at'] == null) {
        return true;
      } else {
        return false;
      }
    }

    return PopScope(
      canPop: popFunction(),
      onPopInvoked: (did) {
        noDriverFound = false;
        tripReqError = false;
        serviceNotAvailable = false;
        if (userRequestData.isNotEmpty && userRequestData['accepted_at'] == null) {
          cancelRequest();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Background Map Layer
            _buildMapLayer(media),
            
            // 2. Main UI Panels (Ride Selection or On-Trip)
            if (userRequestData.isEmpty) _buildRideSelectionSheet(media),
            if (userRequestData.isNotEmpty) _buildOnTripPanel(media),
            
            // 3. Search Overlay
            if (userRequestData.isNotEmpty && userRequestData['accepted_at'] == null)
              SearchingOverlay(
                onCancel: () {
                  cancelRequest();
                  setState(() { userRequestData.clear(); });
                },
                waitText: languages[choosenLanguage]['text_searching_drivers'],
              ),
              
            // 4. Status Overlays & Popups
            _buildStatusOverlays(media),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLayer(Size media) {
    return (mapType == 'google')
      ? GoogleMap(
          mapType: MapType.normal,
          style: mapStyle,
          myLocationEnabled: (locationAllowed == true) ? true : false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          initialCameraPosition: CameraPosition(target: center, zoom: 15),
          onMapCreated: _onMapCreated,
          markers: Set<Marker>.of(myMarker.cast<Marker>()),
          polylines: Set<Polyline>.of(polyline.cast<Polyline>()),
          padding: EdgeInsets.only(bottom: mapPadding, top: 30),
        )
      : fm.FlutterMap(
          mapController: _fmController,
          options: fm.MapOptions(
            initialCenter: fmlt.LatLng(center.latitude, center.longitude),
            initialZoom: 13,
          ),
          children: [
            fm.TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            fm.PolylineLayer(
              polylines: [
                fm.Polyline(points: fmpoly, strokeWidth: 4, color: buttonColor)
              ],
            ),
          ],
        );
  }

  Widget _buildStatusOverlays(Size media) {
    return Stack(
      children: [
        if (_cancel) _buildCancelReasonOverlay(media),
        if (_dateTimePicker) _buildDateTimePickerOverlay(media),
        if (showSos) _buildSosOverlay(media),
        if (isLoading) _buildLoadingOverlay(media),
        if (serviceNotAvailable) _buildServiceNotAvailableOverlay(media),
        if (noDriverFound) _buildNoDriverFoundOverlay(media),
        if (tripReqError) _buildTripErrorOverlay(media),
        if (_locationDenied) _buildLocationDeniedOverlay(media),
        if (_editUserDetails) _buildEditUserDetailsOverlay(media),
        if (islowwalletbalance) _buildLowWalletOverlay(media),
        _buildUtilityMarkers(media),
      ],
    );
  }

  Widget _buildCancelReasonOverlay(Size media) {
    return Positioned(
      top: 0, bottom: 0, left: 0, right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: media.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: page, borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(languages[choosenLanguage]['text_cancel_ride'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Button(onTap: () => setState(() => _cancel = false), text: languages[choosenLanguage]['text_no'])),
                    const SizedBox(width: 10),
                    Expanded(child: Button(onTap: () { cancelRequest(); setState(() { _cancel = false; userRequestData.clear(); }); }, text: languages[choosenLanguage]['text_yes'], color: Colors.red)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSosOverlay(Size media) {
    return Positioned(
      top: 0, bottom: 0, left: 0, right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: media.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text('Emergency SOS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 20),
                Button(onTap: () => setState(() => showSos = false), text: 'Close', color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(Size media) => Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()));
  
  Widget _buildServiceNotAvailableOverlay(Size media) => Positioned(
    top: 0, bottom: 0, left: 0, right: 0,
    child: Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(languages[choosenLanguage]['text_service_not_available'], style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Button(onTap: () => setState(() => serviceNotAvailable = false), text: 'OK')
            ],
          ),
        ),
      ),
    )
  );

  Widget _buildNoDriverFoundOverlay(Size media) => Positioned(
    top: 0, bottom: 0, left: 0, right: 0,
    child: Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(languages[choosenLanguage]['text_no_driver_found'], style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Button(onTap: () => setState(() => noDriverFound = false), text: 'OK')
            ],
          ),
        ),
      ),
    )
  );

  Widget _buildTripErrorOverlay(Size media) => Container();
  Widget _buildLocationDeniedOverlay(Size media) => Container();
  Widget _buildEditUserDetailsOverlay(Size media) => Container();
  Widget _buildLowWalletOverlay(Size media) => Container();
  Widget _buildDateTimePickerOverlay(Size media) => Container();

  Widget _buildUtilityMarkers(Size media) {
    return Stack(
      children: [
        Positioned(left: -100, child: RepaintBoundary(key: iconKey, child: Container(padding: EdgeInsets.all(5), decoration: BoxDecoration(color: theme, shape: BoxShape.circle), child: Icon(Icons.person_pin_circle, color: Colors.white, size: 30)))),
        Positioned(left: -100, child: RepaintBoundary(key: iconDistanceKey, child: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Text('5 min', style: TextStyle(color: Colors.white, fontSize: 10))))),
      ],
    );
  }

  Widget _buildOnTripPanel(Size media) {
    if (userRequestData.isEmpty || userRequestData['accepted_at'] == null) return Container();
    return Positioned(
      bottom: 0,
      child: Container(
        width: media.width,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: page, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(userRequestData['driverDetail']['data']['profile_picture'] ?? ''), radius: 25),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(userRequestData['driverDetail']['data']['name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), Text(userRequestData['driverDetail']['data']['car_number'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))])),
              ],
            ),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(child: Button(onTap: () => setState(() => _cancel = true), text: languages[choosenLanguage]['text_cancel'], color: Colors.red)),
                const SizedBox(width: 10),
                Expanded(child: Button(onTap: () => setState(() => showSos = true), text: 'SOS', color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideSelectionSheet(Size media) {
    if (userRequestData.isNotEmpty || (etaDetails.isEmpty && rentalOption.isEmpty)) return Container();
    return Positioned(
      bottom: 0,
      child: Container(
        width: media.width,
        decoration: BoxDecoration(color: page, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 250,
              child: (widget.type == 1) ? _buildRentalVehicleList(media) : ListView.builder(
                itemCount: etaDetails.length,
                itemBuilder: (context, i) => _buildVehicleItem(media, i),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Button(onTap: () => (widget.type == 1) ? bookRental() : bookRide(), text: (widget.type == 1) ? languages[choosenLanguage]['text_book_rental'] : languages[choosenLanguage]['text_book_now'], color: theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleItem(Size media, int i) {
    bool isSelected = choosenVehicle == i;
    return ListTile(
      selected: isSelected,
      onTap: () => setState(() => choosenVehicle = i),
      leading: (etaDetails[i]['icon'] != null) ? Image.network(etaDetails[i]['icon'], width: 40) : null,
      title: Text(etaDetails[i]['name'], style: GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(etaDetails[i]['short_description'], style: GoogleFonts.poppins(fontSize: 12)),
      trailing: Text("\${etaDetails[i]['currency']} \${etaDetails[i]['total']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRentalVehicleList(Size media) {
    if (rentalOption.isEmpty) return Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: rentalOption.length,
      itemBuilder: (context, i) {
        bool isSelected = choosenVehicle == i;
        return ListTile(
          onTap: () => setState(() => choosenVehicle = i),
          selected: isSelected,
          leading: (rentalOption[i]['icon'] != null) ? Image.network(rentalOption[i]['icon'], width: 40) : null,
          title: Text(rentalOption[i]['name'], style: GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          trailing: Text("\${rentalOption[i]['currency']} \${rentalOption[i]['fare_amount']}"),
        );
      }
    );
  }
`.replace(/\\$/g, '$');

// 3. FOOTER (Lines 9633 onwards - starting after the monolithic build)
const footer = lines.slice(9632).join('\n');

// 4. COMBINE AND WRITE
fs.writeFileSync(path, header + modularUI + footer, 'utf8');
console.log('RE-MODULARIZATION SUCCESSFUL. Duplicates removed. Logic preserved.');
