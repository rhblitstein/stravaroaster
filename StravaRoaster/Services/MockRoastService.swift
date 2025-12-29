import Foundation

class MockRoastService {
    
    enum RoastSeverity: String, CaseIterable {
        case mild = "Mild"
        case spicy = "Spicy"
        case caliente = "Caliente"
        case ghostPepper = "🌶️🌶️🌶️"
    }
    
    func generateRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let roasts = getRoasts(for: activity, severity: severity)
        return roasts.randomElement()!
    }
    
    func generateStatsRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        var roasts: [String] = []
        
        switch severity {
        case .mild:
            roasts = [
                "That \(activity.pacePerMile) pace is... a pace. At least you got out there!",
                "\(String(format: "%.1f", activity.distanceMiles)) miles of pure determination.",
                "Nice work on the \(activity.movingTimeFormatted) of moving time!"
            ]
        case .spicy:
            roasts = [
                "\(activity.pacePerMile) per mile. Some people warm up faster than that.",
                "\(String(format: "%.1f", activity.distanceMiles)) miles in \(activity.movingTimeFormatted). Taking it easy today?",
                "A \(activity.pacePerMile) pace. Bold strategy."
            ]
        case .caliente:
            roasts = [
                "\(activity.pacePerMile) pace? My grandma moves faster, and she's been dead for three years.",
                "\(String(format: "%.1f", activity.distanceMiles)) miles. Some people do that as a recovery session.",
                "You took \(activity.movingTimeFormatted) to go \(String(format: "%.1f", activity.distanceMiles)) miles. Just walk next time."
            ]
        case .ghostPepper:
            roasts = [
                "\(activity.pacePerMile) pace. I've seen faster continental drift.",
                "You covered \(String(format: "%.1f", activity.distanceMiles)) miles in \(activity.movingTimeFormatted). That's not training, that's aggressive standing.",
                "\(activity.pacePerMile) per mile. At what point does this stop being running?"
            ]
        }
        
        return roasts.randomElement()!
    }
    
    func generateStoppageRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let minutes = activity.stoppageTime / 60
        var roasts: [String] = []
        
        switch severity {
        case .mild:
            roasts = [
                "\(minutes) minutes of rest. Hydration is important!",
                "You stopped for \(activity.stoppageTimeFormatted). Taking in the views?",
                "A \(activity.stoppageTimeFormatted) break. Smart recovery strategy."
            ]
        case .spicy:
            roasts = [
                "You stopped for \(minutes) minutes. Was it for water, or to question your life choices?",
                "\(activity.stoppageTimeFormatted) of stopped time. At that point you're basically just sightseeing.",
                "\(minutes) minute break. Did you forget you were supposed to be exercising?"
            ]
        case .caliente:
            roasts = [
                "You stopped for \(minutes) minutes. Did you take a nap mid-workout?",
                "\(activity.stoppageTimeFormatted) of stopped time. Just call it a picnic and be honest with yourself.",
                "\(minutes) minutes? That's not a water break, that's a lifestyle choice."
            ]
        case .ghostPepper:
            roasts = [
                "You stopped for \(activity.stoppageTimeFormatted). At that point just admit you're not cut out for this and go home.",
                "\(minutes) minutes of stoppage. Did you need a moment to catch your breath from walking?",
                "You were stopped longer than some people's entire workouts. Impressive commitment to rest."
            ]
        }
        
        return roasts.randomElement()!
    }
    
    func generateElevationRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let elevation = Int(activity.total_elevation_gain)
        var roasts: [String] = []
        
        if elevation < 30 {
            switch severity {
            case .mild:
                roasts = ["Flat route today! Nothing wrong with keeping it easy."]
            case .spicy:
                roasts = ["\(elevation)m of elevation. Were you actively looking for the flattest route possible?"]
            case .caliente:
                roasts = ["\(elevation)m of elevation. Did you go out of your way to avoid anything resembling a hill?"]
            case .ghostPepper:
                roasts = ["\(elevation)m of elevation gain. You somehow found the flattest possible route. Congrats on your commitment to avoiding challenges."]
            }
        } else {
            switch severity {
            case .mild:
                roasts = ["\(elevation)m of elevation! Those hills aren't going to climb themselves. Nice work!"]
            case .spicy:
                roasts = ["\(elevation)m of climbing at that pace? Must have been quite the scenic tour."]
            case .caliente:
                roasts = ["\(elevation)m of elevation. All that climbing and you still couldn't find some speed?"]
            case .ghostPepper:
                roasts = ["\(elevation)m of climbing. Shame the pace didn't match the effort."]
            }
        }
        
        return roasts.randomElement()!
    }
    
    func generateSocialRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let kudos = activity.kudos_count
        let photos = activity.photo_count ?? 0
        var roasts: [String] = []
        
        switch severity {
        case .mild:
            if kudos > 5 {
                roasts = ["\(kudos) kudos! The people love consistency."]
            } else if kudos == 0 {
                roasts = ["Don't worry about the kudos. You're doing this for you!"]
            } else {
                roasts = ["\(kudos) kudos! Every bit of support counts."]
            }
        case .spicy:
            if kudos == 0 {
                roasts = ["Zero kudos. Even your mom didn't click the button."]
            } else if kudos == 1 {
                roasts = ["One whole kudo. I'm guessing that was your mom."]
            } else if photos > 3 {
                roasts = ["\(photos) photos. Are you training or building an Instagram portfolio?"]
            } else {
                roasts = ["\(kudos) kudos for this performance. Your friends are very generous."]
            }
        case .caliente:
            if kudos < 3 {
                roasts = ["\(kudos) people felt bad enough to give you kudos. That's called pity, not support."]
            } else if photos > 3 {
                roasts = ["\(photos) photos. This was a photoshoot with brief movement breaks, not a workout."]
            } else {
                roasts = ["\(kudos) kudos. The sympathy is palpable."]
            }
        case .ghostPepper:
            if kudos == 0 {
                roasts = ["Zero kudos. Even your mom couldn't be bothered."]
            } else if photos > 0 {
                roasts = ["\(photos) photos because you needed proof you actually left the house. The workout sure isn't evidence of any effort."]
            } else {
                roasts = ["\(kudos) kudos out of pity. Those people feel bad for you, not proud of you."]
            }
        }
        
        return roasts.randomElement()!
    }
    
    func generateSegmentsRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard let segments = activity.segment_efforts else {
            return "No segments to roast."
        }
        
        let prs = segments.filter { $0.isPR }.count
        let legends = segments.filter { $0.isLocalLegend }.count
        var roasts: [String] = []
        
        switch severity {
        case .mild:
            if prs > 0 {
                roasts = ["\(prs) PR\(prs == 1 ? "" : "s")! Look at you setting records!"]
            } else if legends > 0 {
                roasts = ["Local Legend status! You really own these segments."]
            } else {
                roasts = ["\(segments.count) segments completed. Solid effort!"]
            }
        case .spicy:
            if prs == 0 && legends == 0 {
                roasts = ["\(segments.count) segments, zero achievements. Just out here existing."]
            } else if prs > 0 {
                roasts = ["\(prs) PR\(prs == 1 ? "" : "s"). Against yourself. On a flat day. Congrats?"]
            } else {
                roasts = ["Local Legend on segments nobody else runs. Strategic."]
            }
        case .caliente:
            if prs == 0 && legends == 0 {
                roasts = ["\(segments.count) segments and not a single PR. Truly impressive consistency in mediocrity."]
            } else {
                roasts = ["PRs are just participation trophies when you're competing against yourself."]
            }
        case .ghostPepper:
            if prs == 0 && legends == 0 {
                roasts = ["\(segments.count) segments. Zero PRs. Zero achievements. You went outside and somehow came back having accomplished less than if you'd stayed home."]
            } else {
                roasts = ["Setting PRs on segments where you're the only one trying. Participation trophy energy."]
            }
        }
        
        return roasts.randomElement()!
    }
    
    func generateFinalRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        var roasts: [String] = []
        
        switch severity {
        case .mild:
            roasts = [
                "Hey, you showed up. That's what counts!",
                "Every workout is progress. Keep it up!",
                "Not every day is a PR day, and that's okay."
            ]
        case .spicy:
            roasts = [
                "Well, that happened. Better luck next time.",
                "You got out there. That's... something.",
                "At least you tried. Sort of."
            ]
        case .caliente:
            roasts = [
                "This was a workout in the loosest sense of the word.",
                "You moved. Slowly. For a while. Good talk.",
                "Next time, maybe try trying."
            ]
        case .ghostPepper:
            roasts = [
                "This wasn't training. This was procrastination with GPS tracking.",
                "You showed up and decided mediocrity was good enough. Mission accomplished.",
                "Congratulations on completing what most people would call a warm-up. Slowly."
            ]
        }
        
        return roasts.randomElement()!
    }
    
    private func getRoasts(for activity: StravaActivity, severity: RoastSeverity) -> [String] {
        switch severity {
        case .mild:
            return getMildRoasts(for: activity)
        case .spicy:
            return getSpicyRoasts(for: activity)
        case .caliente:
            return getCalienteRoasts(for: activity)
        case .ghostPepper:
            return getGhostPepperRoasts(for: activity)
        }
    }
    
    private func getMildRoasts(for activity: StravaActivity) -> [String] {
        var roasts: [String] = []
        
        roasts.append("Nice job on \"\(activity.name)\"! That \(activity.pacePerMile) pace is... well, it's a pace. At least you got out there!")
        roasts.append("Look at you, racking up \(activity.kudos_count) whole kudos! The people love consistency.")
        roasts.append("\(String(format: "%.1f", activity.distanceMiles)) miles of pure determination. Keep it up!")
        
        if activity.stoppageTime > 60 {
            let stoppageMinutes = activity.stoppageTime / 60
            roasts.append("You stopped for \(stoppageMinutes) minutes during this one. Taking in the views, I hope!")
            roasts.append("\(activity.stoppageTimeFormatted) of stopped time. Hey, hydration is important!")
        }
        
        if activity.total_elevation_gain > 500 {
            roasts.append("\(Int(activity.total_elevation_gain))m of elevation! Those hills aren't going to climb themselves. Nice work!")
        } else if activity.total_elevation_gain < 50 {
            roasts.append("Flat route today, huh? Nothing wrong with keeping it easy!")
        }
        
        if let avgHR = activity.average_heartrate {
            if avgHR > 170 {
                roasts.append("Average heart rate of \(Int(avgHR))? You were working hard out there!")
            } else if avgHR < 140 {
                roasts.append("Nice easy effort with that \(Int(avgHR)) average heart rate. Recovery is training too!")
            }
        }
        
        if let achievements = activity.achievement_count, achievements > 0 {
            roasts.append("\(achievements) achievements! Look at you collecting those digital trophies!")
        }
        
        if let photos = activity.photo_count, photos > 0 {
            roasts.append("\(photos) photos! Great job documenting the journey.")
        }
        
        return roasts
    }
    
    private func getSpicyRoasts(for activity: StravaActivity) -> [String] {
        var roasts: [String] = []
        
        roasts.append("'\(activity.name)' - did you come up with that title before or after the activity knocked the creativity out of you?")
        roasts.append("\(activity.kudos_count) kudos for a \(activity.pacePerMile) pace? Your friends are very generous.")
        roasts.append("You covered \(String(format: "%.1f", activity.distanceMiles)) miles. Some people warm up with that distance, but you do you.")
        
        if activity.stoppageTime > 60 {
            let stoppageMinutes = activity.stoppageTime / 60
            roasts.append("You stopped for \(stoppageMinutes) minutes. Was it for water, or to question your life choices?")
            roasts.append("\(activity.stoppageTimeFormatted) of stopped time. At that point you're basically just sightseeing.")
        }
        
        if let photos = activity.photo_count, photos > 0 {
            roasts.append("You stopped \(photos) times for photos. We call that 'tourism with extra steps.'")
            roasts.append("\(photos) photos on a \(String(format: "%.1f", activity.distanceMiles)) mile workout. Are you training or building an Instagram portfolio?")
        }
        
        if activity.total_elevation_gain < 50 {
            roasts.append("\(Int(activity.total_elevation_gain))m of elevation gain. Were you actively looking for the flattest route possible?")
        } else if activity.total_elevation_gain > 1000 {
            roasts.append("\(Int(activity.total_elevation_gain))m of climbing at that pace? Must have been quite the scenic tour.")
        }
        
        if let avgHR = activity.average_heartrate {
            if avgHR < 130 {
                roasts.append("Average heart rate of \(Int(avgHR))? My resting heart rate is higher than that.")
            } else if avgHR > 180 {
                roasts.append("\(Int(avgHR)) average heart rate. Were you exercising or having a panic attack?")
            }
        }
        
        if let achievements = activity.achievement_count, achievements == 0 {
            roasts.append("Zero achievements. Not a single PR, not even a participation trophy. Tough day out there.")
        }
        
        if activity.kudos_count == 0 {
            roasts.append("Zero kudos. Even your mom didn't click the button.")
        } else if activity.kudos_count == 1 {
            roasts.append("One whole kudo. I'm guessing that was your mom.")
        }
        
        return roasts
    }
    
    private func getCalienteRoasts(for activity: StravaActivity) -> [String] {
        var roasts: [String] = []
        
        roasts.append("You titled this '\(activity.name)' and then proceeded to embarrass that title for \(activity.movingTimeFormatted). Bold choice.")
        roasts.append("A \(activity.pacePerMile) pace? My grandma moves faster than that, and she's been dead for three years.")
        roasts.append("\(activity.pacePerMile) per mile. At what point does this become 'elaborate walking'?")
        roasts.append("\(activity.kudos_count) people felt bad enough to give you kudos. That's called pity, not support.")
        
        if activity.stoppageTime > 120 {
            let stoppageMinutes = activity.stoppageTime / 60
            roasts.append("You stopped for \(stoppageMinutes) minutes. Did you take a nap mid-workout?")
            roasts.append("\(activity.stoppageTimeFormatted) of stopped time. Just call it a picnic and be honest with yourself.")
        }
        
        if let photos = activity.photo_count, photos > 3 {
            roasts.append("\(photos) photos. This was a photoshoot with brief movement breaks, not a workout.")
        }
        
        if activity.total_elevation_gain < 30 {
            roasts.append("\(Int(activity.total_elevation_gain))m of elevation. Did you go out of your way to avoid anything resembling a hill?")
        }
        
        if let avgHR = activity.average_heartrate {
            if avgHR < 130 {
                roasts.append("\(Int(avgHR)) average heart rate. That's basically a leisurely stroll. Try actually exerting yourself sometime.")
            }
        }
        
        if let achievements = activity.achievement_count, achievements == 0 {
            roasts.append("Not a single achievement. You went out there and accomplished absolutely nothing. Impressive in its own way.")
        }
        
        roasts.append("\(String(format: "%.1f", activity.distanceMiles)) miles in \(activity.movingTimeFormatted). Some people do that as a recovery session.")
        
        return roasts
    }
    
    private func getGhostPepperRoasts(for activity: StravaActivity) -> [String] {
        var roasts: [String] = []
        
        roasts.append("This isn't moving, this is aggressive standing with delusions of athleticism. \(activity.pacePerMile) per mile? Are you okay?")
        roasts.append("\(activity.pacePerMile) pace. I've seen faster continental drift.")
        roasts.append("\(activity.kudos_count) kudos. Even your mom couldn't be bothered. Maybe she saw the \(activity.pacePerMile) pace and felt secondhand embarrassment.")
        roasts.append("You got \(activity.kudos_count) kudos out of pity. Those people feel bad for you, not proud of you.")
        roasts.append("You covered \(String(format: "%.1f", activity.distanceMiles)) miles in \(activity.movingTimeFormatted). Congratulations on completing what most people do as a warm-up. Slowly.")
        roasts.append("\(String(format: "%.1f", activity.distanceMiles)) miles. That's cute. Maybe someday you'll work up to a real workout.")
        
        if activity.stoppageTime > 60 {
            roasts.append("You stopped for \(activity.stoppageTimeFormatted). At that point just admit you're not cut out for this and go home.")
        }
        
        if let photos = activity.photo_count, photos > 0 {
            roasts.append("\(photos) photos because you needed proof you actually left the house. The workout sure isn't evidence of any effort.")
        }
        
        if activity.total_elevation_gain < 30 {
            roasts.append("\(Int(activity.total_elevation_gain))m of elevation gain. You somehow found the flattest possible route. Congrats on your commitment to avoiding challenges.")
        }
        
        if let avgHR = activity.average_heartrate {
            if avgHR < 140 {
                roasts.append("\(Int(avgHR)) average heart rate. You barely elevated your pulse above 'sitting on couch eating chips.' Maybe try actually trying next time.")
            }
        }
        
        roasts.append("'\(activity.name)' is a generous title for whatever that performance was. 'Outdoor Nap' would be more accurate.")
        
        if let achievements = activity.achievement_count, achievements == 0 {
            roasts.append("Zero achievements. Zero PRs. Zero anything. You went outside and somehow came back having accomplished less than if you'd stayed home.")
        }
        
        return roasts
    }
}
