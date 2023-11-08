// Filter function for filtering notes:
//Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note)
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
