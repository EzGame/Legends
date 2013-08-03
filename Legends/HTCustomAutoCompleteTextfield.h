//
//  HTAutoCompleteSources.h
//  Legends
//
//  Created by David Zhang on 2013-07-23.
//
//

#import "HTAutocompleteTextField.h"

@interface HTEmailAutocompleteTextField : HTAutocompleteTextField <HTAutocompleteDataSource>

/*
 * A list of email domains to suggest
 */
@property (nonatomic, copy) NSArray *emailDomains; // modify to use your own custom list of email domains

@end


@interface HTUnitTagAutocompleteTextField : HTAutocompleteTextField <HTAutocompleteDataSource>

@property (nonatomic, copy) NSArray *unitTags;

@end