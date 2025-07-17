enum Personality {
  brave(
    'brave',
    'Upright posture, raised fists, loud roars. Shows confidence and defiance',
  ),
  shy('shy', 'Timid gestures, avoids eye contact, prefers quiet corners'),
  cunning('cunning', 'Sly smiles, quick glances, always plotting something'),
  cheerful('cheerful', 'Bright smiles, bouncy movements, spreads joy'),
  grumpy('grumpy', 'Furrowed brows, crossed arms, grumbles often'),
  curious('curious', 'Wide eyes, always exploring, asks endless questions'),
  clumsy('clumsy', 'Trips often, drops things, endearing awkwardness'),
  mysterious('mysterious', 'Enigmatic aura, quiet presence, hidden motives');

  final String description;
  final String name;

  const Personality(this.name, this.description);
}
