//
//  MHIndexEditorController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 18/12/2014.
//
//

#import <Cocoa/Cocoa.h>

@class MODSortedDictionary;
@class MHIndexEditorController;
@class MODIndexOpt;

@protocol MHIndexEditorControllerDelegate <NSObject>
- (void)indexEditorControllerDidCancel:(MHIndexEditorController *)controller;
- (void)indexEditorControllerDidValidate:(MHIndexEditorController *)controller;

@end

@interface MHIndexEditorController : NSWindowController
{
    NSTextField                                 *_nameTextField;
    NSButton                                    *_backgroundButton;
    NSButton                                    *_dropDuplicatesButton;
    NSButton                                    *_isInitializedButton;
    NSButton                                    *_sparseButton;
    NSButton                                    *_uniqueButton;
    NSTableView                                 *_keyTableView;
    
    NSButton                                    *_addKeyButton;
    NSButton                                    *_removeKeyButton;
    NSButton                                    *_cancelButton;
    NSButton                                    *_okButton;
    
    MODSortedDictionary                         *_editedIndex;
    NSMutableArray                              *_indexKeys;
    
    id<MHIndexEditorControllerDelegate>         _delegate;
}
@property (nonatomic, readwrite, weak) id<MHIndexEditorControllerDelegate> delegate;
@property (nonatomic, readonly, assign) MODIndexOpt *indexOptions;
@property (nonatomic, readonly, assign) MODSortedDictionary *keys;

- (id)initWithEditedIndex:(MODSortedDictionary *)index;
- (void)modalForWindow:(NSWindow *)window;

@end
