import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playdate_model.dart';

/// Service for managing playdates and coordinated activities
class PlaydateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ PLAYDATES ============

  /// Create a new playdate
  Future<String> createPlaydate(Playdate playdate) async {
    await _firestore.collection('playdates').doc(playdate.id).set(playdate.toJson());
    return playdate.id;
  }

  /// Get a specific playdate
  Future<Playdate?> getPlaydate(String playdateId) async {
    final doc = await _firestore.collection('playdates').doc(playdateId).get();
    if (!doc.exists) return null;
    return Playdate.fromJson(doc.data()!);
  }

  /// Get all playdates for a parent (organized or invited)
  Future<List<Playdate>> getPlaydatesForParent(String parentId) async {
    // Get playdates organized by this parent
    final organizedSnapshot = await _firestore
        .collection('playdates')
        .where('organizerId', isEqualTo: parentId)
        .orderBy('startTime', descending: false)
        .get();

    // Get playdates where this parent is invited
    final invitedSnapshot = await _firestore
        .collection('playdates')
        .where('invites', arrayContains: parentId) // Simplified - in reality, need to check nested invites
        .orderBy('startTime', descending: false)
        .get();

    final allDocs = [...organizedSnapshot.docs, ...invitedSnapshot.docs];
    final uniqueDocs = {for (var doc in allDocs) doc.id: doc}.values;

    return uniqueDocs
        .map((doc) => Playdate.fromJson(doc.data()))
        .toList();
  }

  /// Get upcoming playdates
  Future<List<Playdate>> getUpcomingPlaydates(String parentId) async {
    final now = DateTime.now();
    final playdates = await getPlaydatesForParent(parentId);
    
    return playdates
        .where((p) => p.startTime.isAfter(now) && p.status != PlaydateStatus.cancelled)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Update playdate
  Future<void> updatePlaydate(Playdate playdate) async {
    await _firestore.collection('playdates').doc(playdate.id).update(playdate.toJson());
  }

  /// Delete playdate
  Future<void> deletePlaydate(String playdateId) async {
    await _firestore.collection('playdates').doc(playdateId).delete();
  }

  /// Update RSVP status
  Future<void> updateRSVP({
    required String playdateId,
    required String parentId,
    required RSVPStatus status,
    String? notes,
  }) async {
    final playdate = await getPlaydate(playdateId);
    if (playdate == null) return;

    // Update the invite status
    final updatedInvites = playdate.invites.map((invite) {
      if (invite.parentId == parentId) {
        return PlaydateInvite(
          parentId: invite.parentId,
          parentName: invite.parentName,
          childIds: invite.childIds,
          childNames: invite.childNames,
          status: status,
          notes: notes ?? invite.notes,
          invitedAt: invite.invitedAt,
          respondedAt: DateTime.now(),
        );
      }
      return invite;
    }).toList();

    // Calculate current participants
    final acceptedCount = updatedInvites.where((i) => i.status == RSVPStatus.accepted).length;

    await _firestore.collection('playdates').doc(playdateId).update({
      'invites': updatedInvites.map((i) => i.toJson()).toList(),
      'currentParticipants': acceptedCount + 1, // +1 for organizer
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ============ SHARED EXPENSES ============

  /// Add a shared expense
  Future<String> addSharedExpense(SharedExpense expense) async {
    await _firestore.collection('shared_expenses').doc(expense.id).set(expense.toJson());
    
    // Update playdate with expense ID
    await _firestore.collection('playdates').doc(expense.playdateId).update({
      'expenseIds': FieldValue.arrayUnion([expense.id]),
      'hasSharedExpenses': true,
    });

    return expense.id;
  }

  /// Get all expenses for a playdate
  Future<List<SharedExpense>> getPlaydateExpenses(String playdateId) async {
    final snapshot = await _firestore
        .collection('shared_expenses')
        .where('playdateId', isEqualTo: playdateId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SharedExpense.fromJson(doc.data()))
        .toList();
  }

  /// Mark expense as paid by a parent
  Future<void> markExpensePaid({
    required String expenseId,
    required String parentId,
  }) async {
    await _firestore.collection('shared_expenses').doc(expenseId).update({
      'paidStatus.$parentId': true,
    });
  }

  /// Calculate balances between parents
  Future<Map<String, ParentBalance>> calculateBalances(String parentId) async {
    // Get all expenses where this parent is involved
    final expensesSnapshot = await _firestore
        .collection('shared_expenses')
        .get();

    final expenses = expensesSnapshot.docs
        .map((doc) => SharedExpense.fromJson(doc.data()))
        .where((expense) => 
          expense.splits.containsKey(parentId) || 
          expense.paidById == parentId)
        .toList();

    // Calculate running balances with each parent
    final balances = <String, double>{};

    for (var expense in expenses) {
      final paidBy = expense.paidById;
      final amountOwed = expense.getAmountOwed(parentId);
      final hasPaid = expense.hasPaid(parentId);

      if (parentId == paidBy) {
        // This parent paid, others owe them
        for (var entry in expense.splits.entries) {
          if (entry.key != parentId) {
            final otherParentId = entry.key;
            final amountOwedToMe = entry.value;
            balances[otherParentId] = (balances[otherParentId] ?? 0) - amountOwedToMe;
          }
        }
      } else {
        // Someone else paid
        if (!hasPaid && amountOwed > 0) {
          balances[paidBy] = (balances[paidBy] ?? 0) + amountOwed;
        }
      }
    }

    // Convert to ParentBalance objects
    final parentBalances = <String, ParentBalance>{};
    for (var entry in balances.entries) {
      final otherParentId = entry.key;
      final balance = entry.value;
      
      final relatedExpenses = expenses
          .where((e) => 
            (e.paidById == parentId && e.splits.containsKey(otherParentId)) ||
            (e.paidById == otherParentId && e.splits.containsKey(parentId)))
          .map((e) => e.id)
          .toList();

      parentBalances[otherParentId] = ParentBalance(
        parent1Id: parentId,
        parent2Id: otherParentId,
        balance: balance,
        relatedExpenseIds: relatedExpenses,
        updatedAt: DateTime.now(),
      );
    }

    return parentBalances;
  }

  /// Get balance with a specific parent
  Future<ParentBalance?> getBalanceWith(String parentId, String otherParentId) async {
    final allBalances = await calculateBalances(parentId);
    return allBalances[otherParentId];
  }

  // ============ TRANSPORTATION ============

  /// Add transportation offer
  Future<void> addTransportationOffer({
    required String playdateId,
    required TransportationOffer offer,
  }) async {
    await _firestore.collection('playdates').doc(playdateId).update({
      'transportationOffers': FieldValue.arrayUnion([offer.toJson()]),
      'needsTransportation': true,
    });
  }

  /// Accept a transportation offer
  Future<void> acceptTransportationOffer({
    required String playdateId,
    required String offerParentId,
    required String acceptingParentId,
  }) async {
    final playdate = await getPlaydate(playdateId);
    if (playdate == null) return;

    // Find and update the offer
    final updatedOffers = playdate.transportationOffers.map((offer) {
      if (offer.parentId == offerParentId && !offer.isFull) {
        return TransportationOffer(
          parentId: offer.parentId,
          parentName: offer.parentName,
          direction: offer.direction,
          availableSeats: offer.availableSeats,
          route: offer.route,
          vehicleInfo: offer.vehicleInfo,
          phoneNumber: offer.phoneNumber,
          acceptedByParentIds: [...offer.acceptedByParentIds, acceptingParentId],
        );
      }
      return offer;
    }).toList();

    await _firestore.collection('playdates').doc(playdateId).update({
      'transportationOffers': updatedOffers.map((o) => o.toJson()).toList(),
    });
  }

  // ============ SEARCH & DISCOVERY ============

  /// Search playdates by location
  Future<List<Playdate>> searchPlaydatesByLocation(String city) async {
    final snapshot = await _firestore
        .collection('playdates')
        .where('location', isEqualTo: city)
        .where('status', whereIn: [PlaydateStatus.upcoming.toString(), PlaydateStatus.confirmed.toString()])
        .orderBy('startTime')
        .get();

    return snapshot.docs
        .map((doc) => Playdate.fromJson(doc.data()))
        .toList();
  }

  /// Get public playdates (for community discovery)
  Future<List<Playdate>> getPublicPlaydates({String? activityType}) async {
    Query query = _firestore
        .collection('playdates')
        .where('status', isEqualTo: 'upcoming')
        .where('currentParticipants', isLessThan: FirebaseFirestore.instance.collection('playdates').doc().get().then((doc) => 
          (doc.data() as Map<String, dynamic>?)?['maxParticipants'] ?? 20));

    if (activityType != null) {
      query = query.where('activityType', isEqualTo: activityType);
    }

    final snapshot = await query
        .orderBy('startTime')
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Playdate.fromJson(doc.data()))
        .toList();
  }

  // ============ STATISTICS ============

  /// Get playdate statistics for a parent
  Future<PlaydateStats> getPlaydateStats(String parentId) async {
    final playdates = await getPlaydatesForParent(parentId);
    
    final organized = playdates.where((p) => p.organizerId == parentId).length;
    final attended = playdates.where((p) => 
      p.invites.any((i) => i.parentId == parentId && i.status == RSVPStatus.accepted)
    ).length;

    final upcoming = playdates.where((p) => 
      p.startTime.isAfter(DateTime.now()) && 
      p.status != PlaydateStatus.cancelled
    ).length;

    return PlaydateStats(
      totalOrganized: organized,
      totalAttended: attended,
      upcomingCount: upcoming,
    );
  }
}

/// Playdate statistics
class PlaydateStats {
  final int totalOrganized;
  final int totalAttended;
  final int upcomingCount;

  PlaydateStats({
    required this.totalOrganized,
    required this.totalAttended,
    required this.upcomingCount,
  });
}

