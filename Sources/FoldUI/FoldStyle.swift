import SwiftUI

// angles are absolute! not relative
public protocol FoldStyle: Animatable {
    associatedtype Forward: Sequence<Angle>
    associatedtype Backward: Sequence<Angle>
    var forward: Forward { get }
    var backward: Backward { get }
}

public struct FoldCommand {
    var next: (Angle) -> Angle
    
    public static func relative(_ angle: Angle) -> Self {
        .init { $0 + angle }
    }
    public static func absolute(_ angle: Angle) -> Self {
        .init { _ in angle }
    }
}

public struct UniformFoldStyle: FoldStyle {
    var command: FoldCommand
    public init(_ command: FoldCommand) {
        self.command = command
    }
    
    public var forward: some Sequence<Angle> {
        sequence(first: .zero, next: command.next).dropFirst()
    }
        
    public var backward: some Sequence<Angle> {
        forward
    }
}

public struct SymmetricFoldStyle<Commands: Sequence<FoldCommand>>: FoldStyle {
    var commands: Commands
    public init(_ commands: Commands) {
        self.commands = commands
    }
    
    public var forward: some Sequence<Angle> {
        commands.reductions(.zero) { angle, command in
            command.next(angle)
        }.dropFirst()
    }
    
    public var backward: some Sequence<Angle> {
        forward
    }
}

// TODO: Do something like an GeometryReader to read the angle
