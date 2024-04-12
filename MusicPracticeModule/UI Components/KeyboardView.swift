//
//  KeyboardView.swift
//  MusicPractice
//
//  Created by kingcyk on 5/26/21.
//

import UIKit

/// Piano keyboard display related
protocol KeyboardDelegate: AnyObject {
    /// Note on events
    func noteOn(note: Int)
    /// Note off events
    func noteOff(note: Int)
}

class KeyboardView: UIView {
    /// Number of octaves displayed at once
    open var octaveCount: Int = 2

    /// Lowest octave displayed
    open var firstOctave: Int = 4

    /// Relative measure of the height of the black keys
    open var topKeyHeightRatio: CGFloat = 0.55

    /// White key color
    open var whiteKeyOff: UIColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

    /// Black key color
    open var blackKeyOff: UIColor = #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

    /// Activated key color
    open var leftKeyOnColor: UIColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    open var rightKeyOnColor: UIColor = #colorLiteral(red: 0.1725490196, green: 0.8784313725, blue: 0.3803921569, alpha: 1)

    /// Class to handle user actions
    open weak var delegate: KeyboardDelegate?

    var oneOctaveSize = CGSize.zero
    var xOffset: CGFloat = 1
    var onKeys = Set<Int>()
    var programmaticOnKeys = Set<Int>()
    var programmaticOnHands = [Int]()


    /// Allows multiple notes to play concurrently
    open var polyphonicMode = false {
        didSet {
            for note in onKeys {
                delegate?.noteOff(note: note)
            }
            onKeys.removeAll()
            setNeedsDisplay()
        }
    }

    let baseMIDINote = 24 // MIDINote 24 is C0
    let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let topKeyNotes = [0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 11]
    let whiteKeyNotes = [0, 2, 4, 5, 7, 9, 11]

    func getNoteName(_ note: Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }

    // MARK: - Initialization
    /// Initialize the keyboard with default info
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
    }

    /// Initialize the keyboard
    init(width: Int,
                height: Int,
                firstOctave: Int = 4,
                octaveCount: Int = 3,
                polyphonic: Bool = false) {
        self.octaveCount = octaveCount
        self.firstOctave = firstOctave
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))
        isMultipleTouchEnabled = true
        polyphonicMode = polyphonic
    }

    /// Initialization within Interface Builder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }

    // MARK: - Storyboard Rendering
    /// Set up the view for rendering in Interface Builder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        contentMode = .redraw
        clipsToBounds = true
    }

    /// Keyboard view size
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 0)
    }

    /// Require constraints
    class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Drawing
    /// Draw the view
    override func draw(_ rect: CGRect) {

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        for index in 0 ..< octaveCount {
            drawOctaveCanvas(index)
        }

        let tempWidth = CGFloat(width) - CGFloat((octaveCount * 7) - 1) * whiteKeySize.width - 1
        let backgroundPath = UIBezierPath(rect: CGRect(x: oneOctaveSize.width * CGFloat(octaveCount),
                                                       y: 0,
                                                       width: tempWidth,
                                                       height: oneOctaveSize.height))
        UIColor.black.setFill()
        backgroundPath.fill()

        let lastC = UIBezierPath(rect:
            CGRect(x: whiteKeyX(0, octaveNumber: octaveCount), y: 1, width: tempWidth, height: whiteKeySize.height))
        whiteKeyColor(0, octaveNumber: octaveCount).setFill()
        lastC.fill()

    }

    /// Draw one octave
    func drawOctaveCanvas(_ octaveNumber: Int) {

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0 + oneOctaveSize.width * CGFloat(octaveNumber),
                                                       y: 0,
                                                       width: oneOctaveSize.width,
                                                       height: oneOctaveSize.height))
        #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1).setFill()
        backgroundPath.fill()

        var whiteKeysPaths = [UIBezierPath]()

        for index in 0 ..< 7 {
            whiteKeysPaths.append(
                UIBezierPath(rect: CGRect(x: whiteKeyX(index, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: whiteKeySize.width - 2,
                                          height: whiteKeySize.height))
            )
            whiteKeyColor(index, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[index].fill()
        }
        
        if octaveNumber == (keyboardShowingRange == .full ? 3 : 2) {
            let string = "M\nC"
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8, weight: .semibold),
                                                                                   NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)])
            attributedString.draw(at: CGPoint(x: whiteKeyX(0, octaveNumber: octaveNumber) + whiteKeySize.width / 4, y: whiteKeySize.height / 1.8))
        } else {
            let string = "C\n\((keyboardShowingRange == .full ? octaveNumber : octaveNumber + 1))"
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8, weight: .semibold),
                                                                                   NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)])
            attributedString.draw(at: CGPoint(x: whiteKeyX(0, octaveNumber: octaveNumber) + whiteKeySize.width / 4, y: whiteKeySize.height / 1.5))
        }

        var topKeyPaths = [UIBezierPath]()

        for index in 0 ..< 28 {
            topKeyPaths.append(
                UIBezierPath(rect: CGRect(x: topKeyX(index, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: topKeySize.width,
                                          height: topKeySize.height))
            )
            topKeyColor(index, octaveNumber: octaveNumber).setFill()
            topKeyPaths[index].fill()
        }
    }

    // MARK: - Touch Handling
    func notesFromTouches(_ touches: Set<UITouch>) -> [Int] {
        var notes = [Int]()
        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                notes.append(note)
            }
        }
        return notes
    }

    func noteFromTouchLocation(_ location: CGPoint ) -> Int? {
        guard bounds.contains(location) else {
            return nil
        }

        let xPoint = location.x - xOffset
        let yPoint = location.y

        var note = 0

        if yPoint > oneOctaveSize.height * topKeyHeightRatio {
            let octNum = Int(xPoint / oneOctaveSize.width)
            let scaledX = xPoint - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))] + baseMIDINote
        } else {
            let octNum = Int(xPoint / oneOctaveSize.width)
            let scaledX = xPoint - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))] + baseMIDINote
        }
        if note >= 0 {
            return note
        } else {
            return nil
        }

    }

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let notes = notesFromTouches(touches)
        for note in notes {
            pressAdded(note)
        }
        verifyTouches(event?.allTouches)
        setNeedsDisplay()
    }

    /// Handle touches completed
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                // verify that there isn't still a touch remaining on same key from another finger
                if var otherTouches = event?.allTouches {
                    otherTouches.remove(touch)
                    if notesFromTouches(otherTouches).doesNotContain(note) {
                        pressRemoved(note, touches: event?.allTouches)
                    }
                }
            }
        }
        verifyTouches(event?.allTouches)
        setNeedsDisplay()
    }

    /// Handle moved touches
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let key = noteFromTouchLocation(touch.location(in: self)),
                key != noteFromTouchLocation(touch.previousLocation(in: self)) {
                pressAdded(key)
                setNeedsDisplay()
            }
        }
        verifyTouches(event?.allTouches)
    }

    /// Handle stopped touches
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        verifyTouches(event?.allTouches)
    }

    // MARK: - Executing Key Presses
    private func pressAdded(_ newNote: Int) {
        if !polyphonicMode {
            for key in onKeys where key != newNote {
                pressRemoved(key)
            }
        }

        if onKeys.doesNotContain(newNote) {
            onKeys.insert(newNote)
            delegate?.noteOn(note: newNote)
        }

    }

    // MARK: - Programmatic Key Pushes
    /// Programmatically trigger key press without calling delegate
    public func programmaticNoteOn(_ note: Int) {
        programmaticOnKeys.insert(note)
        onKeys.insert(note)
        setNeedsDisplay()
    }

    /// Programatically remove key press without calling delegate
    ///
    /// Note: you can programmatically 'release' a note that has been pressed
    /// manually, but in such a case, the delegate.noteOff() will not be called
    /// when the finger is removed
    public func programmaticNoteOff(_ note: Int) {
        programmaticOnKeys.remove(note)
        onKeys.remove(note)
        setNeedsDisplay()
    }

    private func pressRemoved(_ note: Int, touches: Set<UITouch>? = nil) {
        guard onKeys.contains(note) else {
            return
        }
        onKeys.remove(note)
        delegate?.noteOff(note: note)
        if !polyphonicMode {
            // in mono mode, replace with note from highest remaining touch, if it exists
            var remainingNotes = notesFromTouches(touches ?? Set<UITouch>())
            remainingNotes = remainingNotes.filter { $0 != note }
            if let highest = remainingNotes.max() {
                pressAdded(highest)
            }
        }
    }

    private func verifyTouches(_ touches: Set<UITouch>?) {
        // check that current touches conforms to onKeys, remove stuck notes
        let notes = notesFromTouches(touches ?? Set<UITouch>())
        let disjunct = onKeys.subtracting(notes)
        if !disjunct.isEmpty {
            for note in disjunct {
                if programmaticOnKeys.doesNotContain(note) {
                    pressRemoved(note)
                }
            }
        }
    }

    // MARK: - Private helper properties and functions
    var whiteKeySize: CGSize {
        return CGSize(width: oneOctaveSize.width / 7.0, height: oneOctaveSize.height - 2)
    }

    var topKeySize: CGSize {
        return CGSize(width: oneOctaveSize.width / (4 * 7), height: oneOctaveSize.height * topKeyHeightRatio)
    }

    func whiteKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * whiteKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }

    func topKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * topKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }

    func whiteKeyColor(_ n: Int, octaveNumber: Int) -> UIColor {
        if programmaticOnHands.count < onKeys.count {
            return whiteKeyOff
        }
        var keyOnColor = rightKeyOnColor
        for i in 0..<onKeys.count {
            if programmaticOnHands[i] != 1 && [Int](programmaticOnKeys).sorted().reversed()[i] == (firstOctave + octaveNumber) * 12 + whiteKeyNotes[n] + baseMIDINote {
                keyOnColor = leftKeyOnColor
            }
        }
        return onKeys.contains(
            (firstOctave + octaveNumber) * 12 + whiteKeyNotes[n] + baseMIDINote
        ) ? keyOnColor : whiteKeyOff
    }

    func topKeyColor(_ n: Int, octaveNumber: Int) -> UIColor {
        if programmaticOnHands.count < onKeys.count {
            if notesWithSharps[topKeyNotes[n]].range(of: "#") != nil {
                return blackKeyOff
            }
            return #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)
        }
        var keyOnColor = rightKeyOnColor
        for i in 0..<onKeys.count {
            if programmaticOnHands[i] != 1 && [Int](programmaticOnKeys).sorted().reversed()[i] == (firstOctave + octaveNumber) * 12 + topKeyNotes[n] + baseMIDINote {
                keyOnColor = leftKeyOnColor
            }
        }
        if notesWithSharps[topKeyNotes[n]].range(of: "#") != nil {
            return onKeys.contains(
                (firstOctave + octaveNumber) * 12 + topKeyNotes[n] + baseMIDINote
                ) ? keyOnColor : blackKeyOff
        }
        return #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)

    }
}
