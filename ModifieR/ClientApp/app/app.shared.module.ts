
import { AppComponent } from './appComponent/app.component';
import { RouterModule } from '@angular/router';
import { HttpModule } from '@angular/http';
//import 'hammerjs';
import { appRoutes } from './appComponent/routes';
import { HttpClientModule } from '@angular/common/http';

import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import {
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatRadioModule, MatListModule,
    MatIconModule, MatCardModule, MatSlideToggleModule,
    MatSidenavModule, MatCheckboxModule, MatToolbarModule, MatDialogModule, MatTooltipModule
} from '@angular/material';
import { MatStepperModule } from '@angular/material/stepper';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { InferModuleComponent } from './infer-module/infer-module.component';
import { InformationComponent } from './information/information.component';
import { FileUploaderComponent } from './components/file-uploader/file-uploader.component';
import { ReadFileService } from './services/readFile.service';
import { MissingDialog } from './components/dialog/missingDialog.component';

@NgModule({
    declarations: [
        AppComponent,
        AppComponent,
        InferModuleComponent,
        InformationComponent,
        FileUploaderComponent,
        MissingDialog
    ],
    entryComponents: [
        MissingDialog
    ],
    imports: [
        RouterModule.forRoot(appRoutes, { useHash: true }),
        BrowserModule,
        MatDialogModule,
        BrowserAnimationsModule,
        MatButtonModule,
        MatSelectModule,
        MatCheckboxModule,
        MatToolbarModule,
        MatSidenavModule,
        MatFormFieldModule,
        MatSlideToggleModule,
        MatInputModule,
        MatRadioModule,
        MatIconModule,
        MatStepperModule,
        MatCardModule,
        //MatDividerModule,
        MatListModule,
        MatTooltipModule,
        FormsModule,
        ReactiveFormsModule

    ],
     providers: [ReadFileService],

    //,bootstrap: [AppComponent]
})
export class AppModuleShared {
}

