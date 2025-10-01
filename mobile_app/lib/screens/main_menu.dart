// ... unutar _buildDrawer ...
      child: ListView(
        // ... DrawerHeader
        
        // NOVI LINK ZA LIVE DATA
        ListTile(
          leading: const Icon(Icons.speed),
          title: const Text('Live Data'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/liveData');
          },
        ),

        ListTile(
          leading: const Icon(Icons.settings),
          // ... ostatak