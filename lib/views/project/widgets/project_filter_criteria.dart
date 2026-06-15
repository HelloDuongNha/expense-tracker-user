// Data class holding the advanced filter criteria for project searches.
class ProjectFilterCriteria {
  final String date;
  final String status;
  final String owner;

  const ProjectFilterCriteria({
    this.date = '',
    this.status = '',
    this.owner = '',
  });

  // Returns true if any filter field has a value.
  bool get hasAnyFilter {
    bool hasDate = date.trim().isNotEmpty;
    bool hasStatus = status.trim().isNotEmpty;
    bool hasOwner = owner.trim().isNotEmpty;
    return hasDate || hasStatus || hasOwner;
  }
}
